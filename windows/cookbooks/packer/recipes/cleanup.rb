execute 'run cleanmgr' do
  command 'C:\Windows\System32\cleanmgr.exe /sagerun:10﻿'
  ignore_failure true
  only_if { node['kernel']['product_type'] == 'Workstaton' } # cleanmgr isn't on servers
end

execute 'clean SxS' do
  command 'Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase'
  ignore_failure true
  only_if { node['platform_version'].to_f > 6.1 } # command not present on Windows 7
end

powershell_script 'remove unnecesary directories' do
  code <<-EOH
  @(
      "C:\\Recovery",
      "$env:localappdata\\temp\\*",
      "$env:windir\\logs",
      "$env:windir\\winsxs\\manifestcache",
      "C:\\Users\\vagrant\Favorites\\*"
  ) | % {
          if(Test-Path $_) {
              Write-Host "Removing $_"
              try {
                Takeown /d Y /R /f $_
                Icacls $_ /GRANT:r administrators:F /T /c /q  2>&1 | Out-Null
                Remove-Item $_ -Recurse -Force | Out-Null
              } catch { $global:error.RemoveAt(0) }
          }
      }
  EOH
end

# clean all of the event logs
%w(Application Security Setup System).each do |log|
  execute "Cleaning the #{log} event log" do
    command "wevtutil clear-log #{log}"
  end
end

# remove pagefile
registry_key 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' do
  values [{
    name: 'PagingFiles',
    type: :string,
    data: '',
  }]
end
