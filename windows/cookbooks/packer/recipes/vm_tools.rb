# install the correct tools per virtualization system
case node['virtualization']['system']
when 'vbox'
  directory 'C:/Windows/Temp/virtualbox' do
    recursive true
  end

  powershell_script 'install vbox guest additions' do
    code <<-EOH
      Get-ChildItem E:/cert/ -Filter vbox*.cer | ForEach-Object {
          E:/cert/VBoxCertUtil.exe add-trusted-publisher $_.FullName --root $_.FullName
      }

      Start-Process -FilePath "e:/VBoxWindowsAdditions.exe" -ArgumentList "/S" -WorkingDirectory "C:/Windows/Temp/virtualbox" -Wait
    EOH
    ignore_failure true
  end

  directory 'C:/Windows/Temp/virtualbox' do
    action :delete
  end
end
