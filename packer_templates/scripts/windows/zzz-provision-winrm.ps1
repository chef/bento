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

## for troubleshoot purposes, save this script output to a file.
#Start-Transcript C:\winrm-autounattend.txt

## for troubleshoot purposes, save the current user details. this will be later displayed by provision.ps1.
#whoami /all >C:\whoami-autounattend.txt

if (![Environment]::Is64BitProcess) {
    throw 'this must run in a 64-bit PowerShell session'
}

if (!(New-Object System.Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'this must run with Administrator privileges (e.g. in a elevated shell session)'
}

# move all (non-domain) network interfaces into the private profile to make winrm happy (it needs at
# least one private interface; for vagrant its enough to configure the first network interface).
# NB in windows server it would be enough to call winrm -force argument, but
#    in windows client 10, we must set the network interface profile.
Get-NetConnectionProfile `
    | Where-Object {$_.NetworkCategory -ne 'DomainAuthenticated'} `
    | Set-NetConnectionProfile -NetworkCategory Private

# configure WinRM.
Write-Output 'Configuring WinRM...'
winrm quickconfig -quiet
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{CredSSP="true"}'
# make sure the WinRM service startup type is delayed-auto
# even when the default config is auto (e.g. Windows 2019
# changed that default).
# WARN do not be tempted to change the default WinRM service startup type from
#      delayed-auto to auto, as the later proved to be unreliable.
$result = sc.exe config WinRM start= delayed-auto
if ($result -ne '[SC] ChangeServiceConfig SUCCESS') {
    throw "sc.exe config failed with $result"
}

# dump the WinRM configuration.
Write-Output 'WinRM Configuration:'
winrm enumerate winrm/config/listener
winrm get winrm/config
winrm id

# disable UAC remote restrictions.
# see https://support.microsoft.com/en-us/help/951016/description-of-user-account-control-and-remote-restrictions-in-windows
# see https://docs.microsoft.com/en-us/windows/desktop/wmisdk/user-account-control-and-wmi#handling-remote-connections-under-uac
New-ItemProperty `
    -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' `
    -Name LocalAccountTokenFilterPolicy `
    -Value 1 `
    -Force `
    | Out-Null

# make sure winrm can be accessed from any network location.
New-NetFirewallRule `
    -DisplayName WINRM-HTTP-In-TCP-VAGRANT `
    -Direction Inbound `
    -Action Allow `
    -Protocol TCP `
    -LocalPort 5985 `
    | Out-Null
