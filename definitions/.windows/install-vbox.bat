# with this, we can open the iso, and extract the VBoxWindowsAdditions.exe!
# http://downloads.sourceforge.net/sevenzip/7z920.exe
cmd /c certutil -addstore -f "TrustedPublisher" a:oracle-cert.cer
cmd /c e:\VBoxWindowsAdditions-amd64.exe /S
cmd /c shutdown.exe /r /t 0 /d p:2:4 /c "Vagrant reboot for VBoxWindowsAdditions"

