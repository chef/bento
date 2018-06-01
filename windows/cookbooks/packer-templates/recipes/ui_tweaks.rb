# echo ==^> Show file extensions
# :: Default is 1 - hide file extensions
# reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /f /v HideFileExt /t REG_DWORD /d 0
# echo ==^> Show hidden files and folders
# :: Default is 2 - do not show hidden files and folders
# reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /f /v Hidden /t REG_DWORD /d 1
# echo ==^> Display Full path
# :: Default FullPath 0 and FullPathAddress 0
# reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /f /v FullPath /t REG_DWORD /d 1
# reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /f /v FullPathAddress /t REG_DWORD /d 1

# echo ==^> Disabling new network prompt
# reg add "HKLM\System\CurrentControlSet\Control\Network\NewNetworkWindowOff"
