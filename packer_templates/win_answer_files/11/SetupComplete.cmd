@echo off
:: Windows 11 Post-Setup Bootstrap Script (runs as NT AUTHORITY\SYSTEM)
echo [WIN11-SETUPCOMPLETE] Starting SetupComplete bootstrap... > COM1

:: Ensure Administrator and vagrant accounts are enabled, in Administrators group, with password vagrant
net.exe accounts /lockoutthreshold:0
net.exe user Administrator /active:yes
net.exe user Administrator vagrant
net.exe user Administrator /expires:never
net.exe user vagrant /active:yes
net.exe user vagrant vagrant
net.exe user vagrant /expires:never
net.exe localgroup Administrators vagrant /add
net.exe localgroup Administrators Administrator /add

:: Configure registry security policies
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1 /f
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 0 /f
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service" /v AllowBasic /t REG_DWORD /d 1 /f
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WinRM\Service" /v AllowUnencryptedTraffic /t REG_DWORD /d 1 /f
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client" /v AllowBasic /t REG_DWORD /d 1 /f
reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client" /v AllowUnencryptedTraffic /t REG_DWORD /d 1 /f

:: Set network category to private
powershell.exe -ExecutionPolicy Bypass -NoProfile -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force"
powershell.exe -ExecutionPolicy Bypass -NoProfile -Command "$ErrorActionPreference = 'SilentlyContinue'; Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private"

:: Firewall
netsh advfirewall firewall add rule name="Port 5985" dir=in action=allow protocol=TCP localport=5985

:: WinRM service configuration
sc.exe config winrm start= auto
net.exe start winrm
call %windir%\system32\winrm.cmd quickconfig -q -force
call %windir%\system32\winrm.cmd quickconfig -transport:http
call %windir%\system32\winrm.cmd set winrm/config @{MaxTimeoutms="1800000"}
call %windir%\system32\winrm.cmd set winrm/config/winrs @{MaxMemoryPerShellMB="2048"}
call %windir%\system32\winrm.cmd set winrm/config/winrs @{MaxShellsPerUser="50"}
call %windir%\system32\winrm.cmd set winrm/config/winrs @{MaxConcurrentUsers="50"}
call %windir%\system32\winrm.cmd set winrm/config/winrs @{MaxProcessesPerShell="50"}
call %windir%\system32\winrm.cmd set winrm/config/service @{AllowUnencrypted="true"}
call %windir%\system32\winrm.cmd set winrm/config/service/auth @{Basic="true"}
call %windir%\system32\winrm.cmd set winrm/config/service/auth @{Negotiate="true"}
call %windir%\system32\winrm.cmd set winrm/config/client/auth @{Basic="true"}
call %windir%\system32\winrm.cmd set winrm/config/client/auth @{Negotiate="true"}
call %windir%\system32\winrm.cmd set "winrm/config/listener?Address=*+Transport=HTTP" @{Port="5985"}

:: Restart WinRM to apply policies
sc.exe stop winrm
timeout /t 2 /nobreak >nul
sc.exe start winrm

:: Serial Debugging (Release COM1 from kernel EMS for reliable logging)
bcdedit.exe /ems {current} off
bcdedit.exe /bootems off

echo [WIN11-SETUPCOMPLETE] SetupComplete complete, WinRM ready on 5985 > COM1
exit 0
