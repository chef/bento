REG ADD HKLM\Software\Microsoft\Windows\CurrentVersion\WSMAN\Service /v allow_unencrypted /t REG_DWORD /d 1 /f
REG ADD HKLM\Software\Microsoft\Windows\CurrentVersion\WSMAN\Service /v auth_basic /t REG_DWORD /d 1 /f
REG ADD HKLM\Software\Microsoft\Windows\CurrentVersion\WSMAN\Client /v auth_basic /t REG_DWORD /d 1 /f

netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=yes

cmd.exe /c C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -command . c:\windows\setup\scripts\nano_cleanup.ps1 > c:\windows\setup\scripts\cleanup.txt