Set-StrictMode -Version Latest
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

function Write-SerialLog {
    param([string]$message)
    Write-Host $message
    try {
        cmd.exe /c "echo [WIN11-CLEANUP] $message > COM1" 2>$null
    } catch { }
}

trap {
    Write-Host
    Write-Host "ERROR: $_"
    ($_.ScriptStackTrace -split "`r`n") -replace '^(.*)$','ERROR: $1' | Write-Host
    ($_.Exception.ToString() -split "`r`n") -replace '^(.*)$','ERROR EXCEPTION: $1' | Write-Host
    Write-Host
    Exit 1
}

Write-SerialLog "Starting Windows 11 Deep Cleanup Process..."

Write-SerialLog "Executing Cleanmgr automation on all volume caches..."
try {
    $cleanMgrFlags = @(
        'BranchCache',
        'Delivery Optimization Files',
        'Diagnostic Data Viewer Database Files',
        'Downloaded Program Files',
        'Internet Cache Files',
        'Language Pack',
        'Old ChkDsk Files',
        'Previous Installations',
        'Recycle Bin',
        'RetailDemo Offline Content',
        'Service Pack Cleanup',
        'Setup Log Files',
        'System error memory dump files',
        'System error minidump files',
        'Temporary Files',
        'Temporary Setup Files',
        'Thumbnail Cache',
        'Update Cleanup',
        'Upgrade Discarded Files',
        'User file versions',
        'Windows Defender',
        'Windows Error Reporting Archive Files',
        'Windows Error Reporting Queue Files',
        'Windows Error Reporting System Archive Files',
        'Windows Error Reporting System Queue Files',
        'Windows ESD installation files',
        'Windows Upgrade Log Files'
    )

    Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\*' -Name StateFlags0001 -ErrorAction SilentlyContinue | Remove-ItemProperty -Name StateFlags0001 -ErrorAction SilentlyContinue

    foreach ($flag in $cleanMgrFlags) {
        $path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\$flag"
        if (Test-Path $path) {
            New-ItemProperty -Path $path -Name StateFlags0001 -Value 2 -PropertyType DWord -Force -ErrorAction SilentlyContinue | Out-Null
        }
    }

    Start-Process -FilePath CleanMgr.exe -ArgumentList '/sagerun:1' -Wait -ErrorAction SilentlyContinue
    Get-Process -Name cleanmgr,dismhost -ErrorAction SilentlyContinue | Wait-Process -Timeout 120 -ErrorAction SilentlyContinue
} catch {
    Write-SerialLog "CleanMgr note: $_"
}

Write-SerialLog "Disabling and removing Windows Recovery Environment (WinRE)..."
try {
    reagentc.exe /disable
    Remove-Item -Path "C:\Windows\System32\Recovery\Winre.wim" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Recovery" -Recurse -Force -ErrorAction SilentlyContinue
} catch { }

Write-SerialLog "Clearing Windows Event Logs..."
try {
    wevtutil el | ForEach-Object { wevtutil cl "$_" 2>$null }
} catch { }

Write-SerialLog "Stopping background update and caching services..."
function Stop-ServiceForReal($name) {
    try {
        Stop-Service -Name $name -Force -ErrorAction SilentlyContinue
    } catch { }
}
Stop-ServiceForReal TrustedInstaller
Stop-ServiceForReal wuauserv
Stop-ServiceForReal BITS
Stop-ServiceForReal DoSvc
Stop-ServiceForReal SysMain
Stop-ServiceForReal WSearch

Write-SerialLog "Purging temporary files, caches, and logs..."
@(
    "$env:LOCALAPPDATA\Temp\*",
    "$env:windir\Temp\*",
    "$env:windir\Logs\*",
    "$env:windir\Panther\*",
    "$env:windir\WinSxS\ManifestCache\*",
    "$env:windir\SoftwareDistribution\Download\*",
    "$env:windir\SoftwareDistribution\DeliveryOptimization\*",
    "$env:windir\SoftwareDistribution\DataStore\Logs\*",
    "$env:windir\SoftwareDistribution\ScanFile\*",
    "$env:windir\Prefetch\*",
    "$env:windir\Minidump\*",
    "C:\Windows\MEMORY.DMP",
    "C:\Windows\System32\winevt\Logs\*",
    "C:\Windows\ServiceProfiles\LocalService\AppData\Local\FontCache\*",
    "C:\ProgramData\Microsoft\Windows\WER\ReportArchive\*",
    "C:\ProgramData\Microsoft\Windows\WER\ReportQueue\*",
    "C:\ProgramData\Microsoft\Windows\WER\Temp\*",
    "C:\ProgramData\Microsoft\Windows Defender\Scans\History\Store\*",
    "C:\ProgramData\Microsoft\Windows Defender\Definition Updates\Backup\*",
    "C:\ProgramData\Package Cache\*",
    "C:\Program Files (x86)\Microsoft\EdgeUpdate\Download\*",
    "C:\Users\*\AppData\Local\Microsoft\Windows\Explorer	humbcache_*.db",
    "C:\Users\*\AppData\Local\Microsoft\Windows\Explorer\iconcache_*.db",
    "C:\Users\*\AppData\Local\Microsoft\Windows\INetCache\*",
    "C:\Users\*\AppData\Local\Microsoft\Windows\History\*",
    "C:\Users\*\AppData\Local\Microsoft\Windows\WebCache\*",
    "C:\Users\*\AppData\Local\CrashDumps\*",
    "C:\Users\*\AppData\Local\Temp\*",
    "C:\Users\*\AppData\Local\Microsoft\Edge\User Data\Default\Cache\*",
    "C:`$Recycle.Bin\*",
    "C:\Windows.old"
) | ForEach-Object {
    if (Test-Path $_) {
        try {
            Remove-Item $_ -Exclude 'packer-*' -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
        } catch { }
    }
}

Write-SerialLog "Cleaning and resetting WinSxS Component Store..."
try {
    dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase
    dism.exe /Online /Cleanup-Image /SPSuperseded
} catch {
    Write-SerialLog "Component cleanup note: $_"
}

Write-SerialLog "Removing disabled features payloads..."
try {
    Get-WindowsOptionalFeature -Online | Where-Object {$_.State -eq 'Disabled'} | ForEach-Object {
        dism.exe /Online /Quiet /Disable-Feature "/FeatureName:$($_.FeatureName)" /Remove 2>$null
    }
} catch { }

Write-SerialLog "Zeroing and purging pagefile/swapfile for clean shutdown..."
try {
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name PagingFiles -Value @('') -Type MultiString -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name ClearPageFileAtShutdown -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name SwapfileControl -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue | Out-Null
    Remove-Item -Path "C:\swapfile.sys" -Force -ErrorAction SilentlyContinue
} catch { }

Write-SerialLog "Cleanup completed successfully."
exit 0
