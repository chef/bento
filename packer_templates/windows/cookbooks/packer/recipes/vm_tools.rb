# install virtualbox guest additions on vbox guests
if vbox?
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

# install vmware tools on vmware guests
# This is from https://github.com/luciusbono/Packer-Windows10/blob/master/install-guest-tools.ps1
if vmware?
  powershell_script 'install vbox guest additions' do
    code <<-EOH
      $isopath = "C:\\Windows\\Temp\\vmware.iso"
      Mount-DiskImage -ImagePath $isopath
      $exe = ((Get-DiskImage -ImagePath $isopath | Get-Volume).Driveletter + ':\setup.exe')
      $parameters = '/S /v "/qr REBOOT=R"'
      Dismount-DiskImage -ImagePath $isopath
      Remove-Item $isopath
    EOH
  end
end
