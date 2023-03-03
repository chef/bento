# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

$env:chocolateyUseWindowsCompression = 'false'

Write-Host "Downloading Chocolatey ..."
(new-object net.webclient).DownloadFile('https://chocolatey.org/install.ps1', 'C:\Windows\Temp\chocolatey.ps1')

Write-Host "Installing Chocolatey ..."
& C:/Windows/Temp/chocolatey.ps1
