<#
.SYNOPSIS
  Debloat script for Windows 11 based on tiny11builder concepts.
.DESCRIPTION
  Removes bloatware Appx/Provisioned packages, disables telemetry, disables reserved storage,
  shuts down background update download services, and minimizes disk footprint.
#>

function Write-SerialLog {
    param([string]$message, [string]$color = "Yellow")
    Write-Host $message -ForegroundColor $color
    try {
        cmd.exe /c "echo [WIN11-DEBLOAT] $message > COM1" 2>$null
    } catch { }
}

Write-SerialLog "Starting Windows 11 Debloat Process..." "Cyan"

# 1. Disable Reserved Storage to immediately reclaim ~7 GB of disk space
try {
    Write-SerialLog "Disabling Reserved Storage (reclaims ~7GB)..."
    DISM.exe /Online /Set-ReservedStorageState /State:Disabled
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager" -Name "ShippedWithReserves" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager" -Name "PassedPolicy" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
} catch {
    Write-SerialLog "WARN: Could not disable reserved storage: $_"
}

# 2. Comprehensive Appx and Provisioned Package Removal
$packagesToRemove = @(
    "Clipchamp.Clipchamp",
    "Microsoft.549981C3F5F10",
    "Microsoft.BingNews",
    "Microsoft.BingSearch",
    "Microsoft.BingWeather",
    "Microsoft.Copilot",
    "Microsoft.DesktopAppInstaller",
    "Microsoft.GamingApp",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.Messaging",
    "Microsoft.Microsoft3DViewer",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MicrosoftStickyNotes",
    "Microsoft.MixedReality.Portal",
    "Microsoft.NetworkSpeedTest",
    "Microsoft.News",
    "Microsoft.Office.OneNote",
    "Microsoft.OneConnect",
    "Microsoft.OneDriveSync",
    "Microsoft.OutlookForWindows",
    "Microsoft.Paint3D",
    "Microsoft.People",
    "Microsoft.PowerAutomateDesktop",
    "Microsoft.Print3D",
    "Microsoft.ScreenSketch",
    "Microsoft.SkypeApp",
    "Microsoft.StorePurchaseApp",
    "Microsoft.Todos",
    "Microsoft.Wallet",
    "Microsoft.Windows.Ai.Copilot.Provider",
    "Microsoft.Windows.DevHome",
    "Microsoft.WindowsAlarms",
    "Microsoft.WindowsCamera",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsMaps",
    "Microsoft.WindowsSoundRecorder",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxApp",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.YourPhone",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo",
    "MicrosoftCorporationII.MicrosoftFamily",
    "MicrosoftCorporationII.QuickAssist",
    "MicrosoftTeams",
    "MSTeams",
    "microsoft.windowscommunicationsapps",
    "MicrosoftWindows.Client.WebExperience"
)

Write-SerialLog "Removing non-essential AppX and provisioned packages..."
foreach ($package in $packagesToRemove) {
    Get-AppxPackage -Name "*$package*" -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like "*$package*" -or $_.PackageName -like "*$package*" } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

# Wildcard patterns for any residual bloat
$bloatPatterns = @(
    "*Xbox*",
    "*Zune*",
    "*Bing*",
    "*Solitaire*",
    "*FeedbackHub*",
    "*GetHelp*",
    "*YourPhone*",
    "*Clipchamp*",
    "*Copilot*",
    "*WebExperience*",
    "*OutlookForWindows*"
)
foreach ($pattern in $bloatPatterns) {
    Get-AppxPackage -Name $pattern -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $pattern -or $_.PackageName -like $pattern } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

# 3. Disable Telemetry, Diagnostics & Crash Dumps
Write-SerialLog "Disabling Telemetry, Diagnostics, and Crash Dumps..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "MaxTelemetryAllowed" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl" -Name "CrashDumpEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

# 4. Disable Cloud Content, Consumer Suggestions, and Store Auto-Downloads
Write-SerialLog "Disabling Cloud Content and Consumer Features..."
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableSoftLanding" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" -Force -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" -Name "AutoDownload" -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue

New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchUseWeb" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

# 5. Disable Unnecessary Background Services
$servicesToDisable = @(
    "DiagTrack",        # Connected User Experiences and Telemetry
    "dmwappushservice", # WAP Push Message Routing Service
    "SysMain",          # Superfetch / SysMain
    "WSearch",          # Windows Search Indexer
    "MapsBroker",       # Downloaded Maps Manager
    "WerSvc",           # Windows Error Reporting
    "RetailDemo",       # Retail Demo Service
    "DoSvc",            # Delivery Optimization
    "XblAuthManager",   # Xbox Live Auth Manager
    "XblGameSave",      # Xbox Live Game Save
    "XboxNetApiSvc"     # Xbox Live Networking Service
)

Write-SerialLog "Disabling telemetry, search indexing, and background services..."
foreach ($service in $servicesToDisable) {
    Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
}

# 6. Completely Remove OneDrive
Write-SerialLog "Uninstalling OneDrive..."
if (Test-Path "$env:SystemRoot\SysWOW64\OneDriveSetup.exe") {
    Start-Process "$env:SystemRoot\SysWOW64\OneDriveSetup.exe" -ArgumentList "/uninstall" -Wait -NoNewWindow -ErrorAction SilentlyContinue
} elseif (Test-Path "$env:SystemRoot\System32\OneDriveSetup.exe") {
    Start-Process "$env:SystemRoot\System32\OneDriveSetup.exe" -ArgumentList "/uninstall" -Wait -NoNewWindow -ErrorAction SilentlyContinue
}

# Remove OneDrive residual folders
@(
    "$env:LOCALAPPDATA\Microsoft\OneDrive",
    "$env:PROGRAMDATA\Microsoft OneDrive",
    "C:\OneDriveTemp"
) | ForEach-Object {
    if (Test-Path $_) {
        Remove-Item -Path $_ -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-SerialLog "Debloat complete." "Green"
exit 0
