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
# eject removable volume media.

Write-Host 'Downloaing EjectVolumeMedia...'
$ejectVolumeMediaExeUrl = 'https://github.com/rgl/EjectVolumeMedia/releases/download/v1.0.0/EjectVolumeMedia.exe'
$ejectVolumeMediaExeHash = 'f7863394085e1b3c5aa999808b012fba577b4a027804ea292abf7962e5467ba0'
$ejectVolumeMediaExe = "$env:TEMP\EjectVolumeMedia.exe"
Invoke-WebRequest $ejectVolumeMediaExeUrl -OutFile $ejectVolumeMediaExe
$ejectVolumeMediaExeActualHash = (Get-FileHash $ejectVolumeMediaExe -Algorithm SHA256).Hash
if ($ejectVolumeMediaExeActualHash -ne $ejectVolumeMediaExeHash) {
    throw "the $ejectVolumeMediaExeUrl file hash $ejectVolumeMediaExeActualHash does not match the expected $ejectVolumeMediaExeHash"
}

Get-Volume | Where-Object {$_.DriveType -ne 'Fixed' -and $_.DriveLetter} | ForEach-Object {
    &$ejectVolumeMediaExe $_.DriveLetter
}
