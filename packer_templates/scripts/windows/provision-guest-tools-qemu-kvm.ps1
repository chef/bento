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

$systemVendor = (Get-CimInstance -ClassName Win32_ComputerSystemProduct -Property Vendor).Vendor
if ($systemVendor -eq 'QEMU') {
    # qemu-kvm.
    $guestToolsUrl = "http://$env:PACKER_HTTP_ADDR/drivers/virtio-win-guest-tools.exe"
    $guestTools = "$env:TEMP\$(Split-Path -Leaf $guestToolsUrl)"
    $guestToolsLog = "$guestTools.log"
    Write-Host "Downloading the guest tools from $guestToolsUrl..."
    Invoke-WebRequest $guestToolsUrl -OutFile $guestTools
    Write-Host 'Installing the guest tools...'
    &$guestTools /install /norestart /quiet /log $guestToolsLog | Out-String -Stream
    if ($LASTEXITCODE) {
        throw "failed to install guest tools with exit code $LASTEXITCODE"
    }
    Write-Host "Done installing the guest tools."
} else {
    Write-Host "Not QEMU machine exiting"
    Exit 0
}
