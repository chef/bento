Write-Host "Performing the WinRM setup necessary to get the host ready for packer to run Chef..."

# Make 100% sure we prevent Packer from connecting to WinRM while we
# attempt to configure everything
Disable-NetFirewallRule -DisplayGroup 'Windows Remote Management'

# Disable UAC
Set-ItemProperty -Path "registry::HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0

# parts of this are from https://github.com/luciusbono/Packer-Windows10/blob/master/configure-winrm.ps1
# and https://github.com/rgl/windows-2016-vagrant/blob/master/winrm.ps1

# Supress network location Prompt
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff" -Force

# The above suppresses the prompt but defaults to "Public" which prevents WinRM from being enabled even with the SkipNetworkProfileCheck arg
# This command sets any network connections detected to Private to allow WinRM to be configured and started
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory "Private"

# Does a lot: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/enable-psremoting?view=powershell-6
Enable-PSRemoting -SkipNetworkProfileCheck -Force
# May not be necessary since we set the profile to Private above
Set-NetFirewallRule -Name "WINRM-HTTP-In-TCP" -RemoteAddress Any # allow winrm over public profile interfaces

Write-Host '* Deleting any pre-existing listeners'
winrm delete winrm/config/listener?Address=*+Transport=HTTP  2>$Null
winrm delete winrm/config/listener?Address=*+Transport=HTTPS 2>$Null
Write-Host '* Creating an HTTP listener'
winrm create winrm/config/listener?Address=*+Transport=HTTP | Out-Null
winrm create winrm/config/listener?Address=*+Transport=HTTPS | Out-Null

winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="2048"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'

# Restart WinRM service
Stop-Service -Name "winrm"
Set-Service -Name "winrm" -StartupType "Automatic"
Start-Service -Name "winrm"

# Enable WinRM in Firewall for any remote address
Get-NetFirewallRule -DisplayGroup "Windows Remote Management" | Get-NetFirewallAddressFilter | Set-NetFirewallAddressFilter -RemoteAddress Any
Enable-NetFirewallRule -DisplayGroup "Windows Remote Management"

# Reset auto logon count
# https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-shell-setup-autologon-logoncount#logoncount-known-issue
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoLogonCount -Value 0

# Allow time to view output before window is closed
Start-Sleep -Seconds 2

exit 0
