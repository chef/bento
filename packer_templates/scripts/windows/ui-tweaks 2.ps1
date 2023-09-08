Set-StrictMode -Version Latest
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

trap {
    Write-Host
    Write-Host "ERROR: $_"
    ($_.ScriptStackTrace -split '\r?\n') -replace '^(.*)$','ERROR: $1' | Write-Host
    ($_.Exception.ToString() -split '\r?\n') -replace '^(.*)$','ERROR EXCEPTION: $1' | Write-Host
    Write-Host
    Write-Host 'Sleeping for 60m to give you time to look around the virtual machine before self-destruction...'
    Start-Sleep -Seconds (60*60)
    Exit 1
}

@(
    # Show file extensions
    {Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name HideFileExt -Type DWORD -Value 0}
    # Show hidden files
    {Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name Hidden -Type DWORD -Value 1}
    # Launch explorer to the PC not the user
    {Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name LaunchTo -Type DWORD -Value 1}
    {Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name FullPathAddress -Type DWORD -Value 1}
    # Disable notification popups
    {Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name EnableBalloonTips -Type DWORD -Value 0}
    # Disable error reporting popups
    {Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\Windows Error Reporting' -Name DontShowUI -Type DWORD -Value 0}
    # Disable prompting for a shutdown reason
    {Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability' -Name ShutdownReasonOn -Type DWORD -Value 0}
    # Set visual effects to best performance
    {Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name VisualFXSetting -Type DWORD -Value 2}
    # Dont use visual styles on windows and buttons
    {Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ThemeManager' -Name ThemeActive -Type DWORD -Value 1}
    # Dont use common tasks in folders
    {Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name WebView -Type DWORD -Value 0}
    # Dont use drop shadows for icon labels on the desktop
    {Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name ListviewShadow -Type DWORD -Value 0}
    # Dont use a background image for each folder type
    {Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name ListviewWatermark -Type DWORD -Value 0}
    # Dont slide taskbar buttons
    {Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name TaskbarAnimations -Type DWORD -Value 0}
    # Dont animate windows when minimizing and maximizing
    {Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\WindowMetrics' -Name MinAnimate -Type STRING -Value 0}
    # Dont show window contents while dragging
    {Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name DragFullWindows -Type STRING -Value 0}
    # Dont Smooth edges of screen fonts
    {Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name FontSmoothing -Type STRING -Value 0}
    # Dont smooth scroll list boxes
    # Dont slide open combo boxes
    # Dont fade or slide menus into view
    # Dont show shadows under mouse pointer
    # Dont fade or slide tooltips into view
    # Dont fade out menu items after clicking
    # Dont show shadows under menus
    {Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name UserPreferencesMask -Type BINARY -Value (90,12,01,80)}
) | ForEach-Object {
    try
    {
        Invoke-Command -ScriptBlock $_
    }
    catch
    {
        Write-Host "WARN Failed to run: $_"
    }
}
