cmd /c certutil -addstore -f "TrustedPublisher" a:oracle-cert.cer
cmd /c e:\VBoxWindowsAdditions-amd64.exe /S
cmd /c shutdown.exe /r /t 5 /d p:2:4 /c "Vagrant reboot for VBoxWindowsAdditions"

