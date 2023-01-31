#MIT License
#
#Copyright (c) 2017 Rui Lopes
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

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


#
# enable TLS 1.2.

[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol `
    -bor [Net.SecurityProtocolType]::Tls12


#
# run automatic maintenance.

Add-Type @'
using System;
using System.Runtime.InteropServices;

public static class Windows
{
    [DllImport("kernel32", SetLastError=true)]
    public static extern UInt64 GetTickCount64();

    public static TimeSpan GetUptime()
    {
        return TimeSpan.FromMilliseconds(GetTickCount64());
    }
}
'@

function Wait-Condition {
    param(
      [scriptblock]$Condition,
      [int]$DebounceSeconds=15
    )
    process {
        $begin = [Windows]::GetUptime()
        do {
            Start-Sleep -Seconds 3
            try {
              $result = &$Condition
            } catch {
              $result = $false
            }
            if (-not $result) {
                $begin = [Windows]::GetUptime()
                continue
            }
        } while ((([Windows]::GetUptime()) - $begin).TotalSeconds -lt $DebounceSeconds)
    }
}

function Get-ScheduledTasks() {
    $s = New-Object -ComObject 'Schedule.Service'
    try {
        $s.Connect()
        Get-ScheduledTasksInternal $s.GetFolder('\')
    } finally {
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($s) | Out-Null
    }
}

function Get-ScheduledTasksInternal($Folder) {
    $Folder.GetTasks(0)
    $Folder.GetFolders(0) | ForEach-Object {
        Get-ScheduledTasksInternal $_
    }
}

function Test-IsMaintenanceTask([xml]$definition) {
    # see MaintenanceSettings (maintenanceSettingsType) Element at https://msdn.microsoft.com/en-us/library/windows/desktop/hh832151(v=vs.85).aspx
    $ns = New-Object System.Xml.XmlNamespaceManager($definition.NameTable)
    $ns.AddNamespace('t', $definition.DocumentElement.NamespaceURI)
    $null -ne $definition.SelectSingleNode("/t:Task/t:Settings/t:MaintenanceSettings", $ns)
}

Write-Host 'Running Automatic Maintenance...'
MSchedExe.exe Start
Wait-Condition {@(Get-ScheduledTasks | Where-Object {($_.State -ge 4) -and (Test-IsMaintenanceTask $_.XML)}).Count -eq 0} -DebounceSeconds 60


#
# generate the .net frameworks native images.
# NB this is normally done in the Automatic Maintenance step, but for
#    some reason, sometimes its not.
# see https://docs.microsoft.com/en-us/dotnet/framework/tools/ngen-exe-native-image-generator

Get-ChildItem "$env:windir\Microsoft.NET\*\*\ngen.exe" | ForEach-Object {
    Write-Host "Generating the .NET Framework native images with $_..."
    &$_ executeQueuedItems /nologo /silent
}


#
# remove temporary files.
# NB we ignore the packer generated files so it won't complain in the output.

Write-Host 'Stopping services that might interfere with temporary file removal...'
function Stop-ServiceForReal($name) {
    while ($true) {
        Stop-Service -ErrorAction SilentlyContinue $name
        if ((Get-Service $name).Status -eq 'Stopped') {
            break
        }
    }
}
Stop-ServiceForReal TrustedInstaller   # Windows Modules Installer
Stop-ServiceForReal wuauserv           # Windows Update
Stop-ServiceForReal BITS               # Background Intelligent Transfer Service
@(
    "$env:LOCALAPPDATA\Temp\*"
    "$env:windir\Temp\*"
    "$env:windir\Logs\*"
    "$env:windir\Panther\*"
    "$env:windir\WinSxS\ManifestCache\*"
    "$env:windir\SoftwareDistribution\Download"
) | Where-Object {Test-Path $_} | ForEach-Object {
    Write-Host "Removing temporary files $_..."
    try {
        takeown.exe /D Y /R /F $_ | Out-Null
        icacls.exe $_ /grant:r Administrators:F /T /C /Q 2>&1 | Out-Null
    } catch {
        Write-Host "Ignoring taking ownership of temporary files error: $_"
    }
    try {
        Remove-Item $_ -Exclude 'packer-*' -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    } catch {
        Write-Host "Ignoring failure to remove files error: $_"
    }
}


#
# cleanup the WinSxS folder.

# NB even thou the automatic maintenance includes a component cleanup task,
#    it will not clean everything, as such, dism will clean the rest.
# NB to analyse the used space use: dism.exe /Online /Cleanup-Image /AnalyzeComponentStore
# see https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/clean-up-the-winsxs-folder
Write-Host 'Cleaning up the WinSxS folder...'
dism.exe /Online /Quiet /Cleanup-Image /StartComponentCleanup /ResetBase
if ($LASTEXITCODE) {
    throw "Failed with Exit Code $LASTEXITCODE"
}

# NB even after cleaning up the WinSxS folder the "Backups and Disabled Features"
#    field of the analysis report will display a non-zero number because the
#    disabled features packages are still on disk. you can remove them with:
#       Get-WindowsOptionalFeature -Online `
#           | Where-Object {$_.State -eq 'Disabled'} `
#           | ForEach-Object {
#               Write-Host "Removing feature $($_.FeatureName)..."
#               dism.exe /Online /Quiet /Disable-Feature "/FeatureName:$($_.FeatureName)" /Remove
#           }
#    NB a removed feature can still be installed from other sources (e.g. windows update).
Write-Host 'Analyzing the WinSxS folder...'
dism.exe /Online /Cleanup-Image /AnalyzeComponentStore


#
# reclaim the free disk space.

Write-Host 'Reclaiming the free disk space...'
$results = defrag.exe C: /H /L
if ($results -eq 'The operation completed successfully.')
{
    $results
}
else
{
    if ((Get-CimInstance Win32_OperatingSystem).version -eq "6.3.9600")
    {
        return
    }
    else
    {
        Write-Host 'Zero filling the free disk space...'
        (New-Object System.Net.WebClient).DownloadFile('https://download.sysinternals.com/files/SDelete.zip', "$env:TEMP\SDelete.zip")
        Expand-Archive "$env:TEMP\SDelete.zip" $env:TEMP
        Remove-Item "$env:TEMP\SDelete.zip"
        &"$env:TEMP\sdelete64.exe" -accepteula -z C:
    }
}
