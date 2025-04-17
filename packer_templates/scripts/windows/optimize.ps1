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

Write-Host "Optimizing Drive"
Optimize-Volume -DriveLetter C
compact.exe /compactOS:always

#
# reclaim the free disk space.

Write-Host "Optimizing Drive"
Optimize-Volume -DriveLetter C -Analyze -Defrag

Write-Host "Wiping empty space on disk..."
$FilePath = "C:\zero.tmp"
$Volume = Get-WmiObject win32_logicaldisk -filter "DeviceID='C:'"
$ArraySize = 64kb
$SpaceToLeave = $Volume.Size * 0.05
$FileSize = $Volume.FreeSpace - $SpacetoLeave
$ZeroArray = new-object byte[]($ArraySize)

$Stream = [io.File]::OpenWrite($FilePath)
try {
   $CurFileSize = 0
    while($CurFileSize -lt $FileSize) {
        $Stream.Write($ZeroArray, 0, $ZeroArray.Length)
        $CurFileSize += $ZeroArray.Length
    }
}
finally {
    if($Stream) {
        $Stream.Close()
    }
}

Remove-Item $FilePath
