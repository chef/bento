Write-Host "Performing the WinRM setup necessary to get the host ready for packer to run Chef..."

# this is from https://github.com/luciusbono/Packer-Windows10/blob/master/configure-winrm.ps1
# and https://github.com/rgl/windows-2016-vagrant/blob/master/winrm.ps1

# Supress network location Prompt
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff" -Force

# Set network to private as required by WinRM
Get-NetConnectionProfile `
    | Where-Object {$_.NetworkCategory -ne 'DomainAuthenticated'} `
    | Set-NetConnectionProfile -NetworkCategory Private

winrm quickconfig -q
winrm set "winrm/config" '@{MaxTimeoutms="1800000"}'
winrm set "winrm/config/winrs" '@{MaxMemoryPerShellMB="2048"}'
winrm set "winrm/config/service" '@{AllowUnencrypted="true"}'
winrm set "winrm/config/service/auth" '@{Basic="true"}'

# Enable the WinRM Firewall rules
$winRmFirewallRuleNames = @(
    'WINRM-HTTP-In-TCP',        # Windows Remote Management (HTTP-In)
    'WINRM-HTTP-In-TCP-PUBLIC'  # Windows Remote Management (HTTP-In)   # Windows Server
    'WINRM-HTTP-In-TCP-NoScope' # Windows Remote Management (HTTP-In)   # Windows 10
)
Get-NetFirewallRule -Direction Inbound -Enabled False `
    | Where-Object {$winRmFirewallRuleNames -contains $_.Name} `
| Set-NetFirewallRule -Enable True

sc.exe config WinRM start= delayed-auto

exit 0
