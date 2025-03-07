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
    #Write-Host
    #Write-Host 'whoami from autounattend:'
    #Get-Content C:\whoami-autounattend.txt | ForEach-Object { Write-Host "whoami from autounattend: $_" }
    #Write-Host 'whoami from current WinRM session:'
    #whoami /all >C:\whoami-winrm.txt
    #Get-Content C:\whoami-winrm.txt | ForEach-Object { Write-Host "whoami from winrm: $_" }
    Write-Host
    Write-Host "ERROR: $_"
    ($_.ScriptStackTrace -split '\r?\n') -replace '^(.*)$','ERROR: $1' | Write-Host
    ($_.Exception.ToString() -split '\r?\n') -replace '^(.*)$','ERROR EXCEPTION: $1' | Write-Host
    Write-Host
    Write-Host 'Sleeping for 60m to give you time to look around the virtual machine before self-destruction...'
    Start-Sleep -Seconds (60*60)
    Exit 1
}

Write-Host 'Setting the vagrant account properties...'
# see the ADS_USER_FLAG_ENUM enumeration at https://msdn.microsoft.com/en-us/library/aa772300(v=vs.85).aspx
$AdsScript              = 0x00001
$AdsAccountDisable      = 0x00002
$AdsNormalAccount       = 0x00200
$AdsDontExpirePassword  = 0x10000
$account = [ADSI]'WinNT://./vagrant'
$account.Userflags = $AdsNormalAccount -bor $AdsDontExpirePassword
$account.SetInfo()

Write-Host 'Setting the Administrator account properties...'
$account = [ADSI]'WinNT://./Administrator'
$account.Userflags = $AdsNormalAccount -bor $AdsDontExpirePassword -bor $AdsAccountDisable
$account.SetInfo()

Write-Host 'Disabling Automatic Private IP Addressing (APIPA)...'
Set-ItemProperty `
    -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' `
    -Name IPAutoconfigurationEnabled `
    -Value 0

Write-Host 'Disabling IPv6...'
Set-ItemProperty `
    -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters' `
    -Name DisabledComponents `
    -Value 0xff

Write-Host 'Disabling the Windows Boot Manager menu...'
# NB to have the menu show with a lower timeout, run this instead: bcdedit /timeout 2
#    NB with a timeout of 2 you can still press F8 to show the boot manager menu.
bcdedit /set '{bootmgr}' displaybootmenu no

Write-Host "Enable TLS 1.2."
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol `
    -bor [Net.SecurityProtocolType]::Tls12

if (![Environment]::Is64BitProcess) {
    throw 'this must run in a 64-bit PowerShell session'
}

if (!(New-Object System.Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'this must run with Administrator privileges (e.g. in a elevated shell session)'
}

Add-Type -A System.IO.Compression.FileSystem

# install Guest Additions.
Write-Output "Looking for Guest Tools for $env:PACKER_BUILDER_TYPE..."
$volList = Get-Volume | Where-Object {$_.DriveType -ne 'Fixed' -and $_.DriveLetter}
switch ($env:PACKER_BUILDER_TYPE) {
    {$_ -in "virtualbox-iso", "virtualbox-ovf"} {
        # Actions for VirtualBox ISO builder
        foreach( $vol in $volList ) {
            $letter = $vol.DriveLetter
            $exe = "${letter}:\VBoxWindowsAdditions.exe"
            $installed = $false
            if( Test-Path -LiteralPath $exe ) {
                Write-host "Guest Tools found at $exe"
                try {
                    Write-Host 'Installing the VirtualBox Guest Additions...'
                    $certs = "${letter}:\cert"
                    Start-Process -FilePath "${certs}\VBoxCertUtil.exe" -ArgumentList "add-trusted-publisher ${certs}\vbox*.cer", "--root ${certs}\vbox*.cer"  -Wait
                    Start-Process -FilePath $exe -ArgumentList '/with_wddm', '/S' -Wait
                    $installed = $true
                    break
                }
                catch {
                    throw "failed to install guest tools with exit code $LASTEXITCODE"
                }
            } else {
                Write-Host "Guest Tools NOT FOUND at $exe"
            }
        }
        if ( $installed ) {
            Write-Host "Done installing the guest tools."
        } else {
            throw "Guest Tools not found."
        }
        break
    }
    {$_ -in "vmware-iso", "vmware-vmx"} {
        # Actions for VMware ISO builder
        Write-Host 'Mounting VMware Tools ISO...'
        Mount-DiskImage -ImagePath C:\vmware-tools.iso -PassThru | Get-Volume
        $volList = Get-Volume | Where-Object {$_.DriveType -ne 'Fixed' -and $_.DriveLetter}
        foreach( $vol in $volList ) {
            $letter = $vol.DriveLetter
            $exe = "${letter}:\setup.exe"
            $installed = $false
            if( Test-Path -LiteralPath $exe ) {
                Write-host "Guest Tools found at $exe"
                try {
                    Write-Host 'Installing VMware Tools...'
                    Start-Process -FilePath $exe -ArgumentList '/S /v /qn REBOOT=R' -Wait
                    $installed = $true
                    break
                }
                catch {
                    throw "failed to install guest tools with exit code $LASTEXITCODE"
                }
            } else {
                Write-Host "Guest Tools NOT FOUND at $exe"
            }
        }
        Dismount-DiskImage -ImagePath C:\vmware-tools.iso
        Remove-Item C:\vmware-tools.iso
        if ( $installed ) {
            Write-Host "Done installing the guest tools."
        } else {
            throw "Guest Tools not found. Skipping installation."
        }
        break
    }
    {$_ -in "parallels-iso", "parallels-pvm"} {
        # Actions for Parallels ISO builder
        foreach( $vol in $volList ) {
            $letter = $vol.DriveLetter
            $exe = "${letter}:\PTAgent.exe"
            $installed = $false
            if( Test-Path -LiteralPath $exe ) {
                Write-host "Guest Tools found at $exe"
                try {
                    Write-Host 'Installing the Parallels Tools for Guest VM...'
                    Start-Process -FilePath $exe -ArgumentList '/install_silent' -Wait
                    $installed = $true
                    break
                }
                catch {
                    throw "failed to install guest tools with exit code $LASTEXITCODE"
                }
                Start-Process -FilePath $exe -ArgumentList '/install_silent' -Wait
                break
            } else {
                Write-Host "Guest Tools NOT FOUND at $exe"
            }
        }
        if ( $installed ) {
            Write-Host "Done installing the guest tools."
        } else {
            throw "Guest Tools not found."
        }
        break
    }
    "qemu" {
        # Actions for QEMU builder
        foreach( $vol in $volList ) {
            $letter = $vol.DriveLetter
            $exe = "${letter}:\virtio-win-guest-tools.exe"
            $installed = $false
            if( Test-Path -LiteralPath $exe ) {
                Write-host "Guest Tools found at $exe"
                try {
                    Write-Host 'Installing the guest tools...'
                    Start-Process -FilePath $exe -ArgumentList '/passive', '/norestart' -Wait
                    $installed = $true
                    break
                }
                catch {
                    throw "failed to install guest tools with exit code $LASTEXITCODE"
                }
            } else {
                Write-Host "Guest Tools NOT FOUND at $exe"
            }
        }
        if ( $installed ) {
            Write-Host "Done installing the guest tools."
        } else {
            throw "Guest Tools not found."
        }
        break
    }
    "hyperv-iso" {
        # Actions for Hyper-V ISO builder
        # do nothing. Hyper-V enlightments are already bundled with Windows.
        break
    }
    default {
        throw "Unknown PACKER_BUILDER_TYPE: $env:PACKER_BUILDER_TYPE"
    }
}
