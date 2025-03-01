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

# enable TLS 1.2.
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
$systemVendor = (Get-CimInstance -ClassName Win32_ComputerSystemProduct -Property Vendor).Vendor
if ($systemVendor -eq 'QEMU') {
    Write-Host 'Installing the guest tools...'
    foreach( $letter in 'DEFGHIJKLMNOPQRSTUVWXYZ'.ToCharArray() ) {
        $exe = "${letter}:\virtio-win-guest-tools.exe"
        if( Test-Path -LiteralPath $exe ) {
            Start-Process -FilePath $exe -ArgumentList '/passive', '/norestart' -Wait
            break
        } else {
            Write-Host 'VirtIO Guest Tools image (virtio-win-*.iso) is not attached to this VM.'
        }
    }
    if ($LASTEXITCODE) {
        throw "failed to install guest tools with exit code $LASTEXITCODE"
    }
    Write-Host "Done installing the guest tools."
} elseif ($systemVendor -eq 'innotek GmbH') {
    Write-Host 'Installing the VirtualBox Guest Additions...'
    foreach( $letter in 'DEFGHIJKLMNOPQRSTUVWXYZ'.ToCharArray() ) {
        $exe = "${letter}:\VBoxWindowsAdditions.exe"
        if( Test-Path -LiteralPath $exe ) {
            $certs = "${letter}:\cert"
            Start-Process -FilePath "${certs}\VBoxCertUtil.exe" -ArgumentList "add-trusted-publisher ${certs}\vbox*.cer", "--root ${certs}\vbox*.cer"  -Wait
            Start-Process -FilePath $exe -ArgumentList '/with_wddm', '/S' -Wait
            break
        } else {
            Write-Host 'VBoxGuestAdditions.iso is not attached to this VM.'
        }
    }
    if ($LASTEXITCODE) {
        throw "failed to install Guest Additions with exit code $LASTEXITCODE"
    }
    Write-Host "Done installing the VirtualBox Guest Additions."
} elseif ($systemVendor -eq 'Microsoft Corporation') {
    # do nothing. Hyper-V enlightments are already bundled with Windows.
} elseif ($systemVendor -eq 'VMware, Inc.') {
    Write-Host 'Mounting VMware Tools ISO...'
    Mount-DiskImage -ImagePath C:\vmware-tools.iso -PassThru | Get-Volume
    Write-Host 'Installing VMware Tools...'
    $os_type = (Get-WmiObject -Class Win32_ComputerSystem).SystemType -match ‘(x64)’
    if ($os_type) {
        $setup = 'setup64.exe'
    } else {
        $setup = 'setup.exe'
    }
    foreach( $letter in 'DEFGHIJKLMNOPQRSTUVWXYZ'.ToCharArray() ) {
        $exe = "${letter}:\${setup}"
        if( ( Get-Item -LiteralPath $exe -ErrorAction 'SilentlyContinue' | Select-Object -ExpandProperty 'VersionInfo' | Select-Object -ExpandProperty 'ProductName' ) -eq 'VMware Tools' ) {
            Start-Process -FilePath $exe -ArgumentList '/s /v /qn REBOOT=R' -Wait
            break
        } else {
            Write-Host 'VMware Tools image (windows.iso) is not attached to this VM.'
        }
    }
    if ($LASTEXITCODE) {
        throw "failed to install with exit code $LASTEXITCODE"
    }
    Dismount-DiskImage -ImagePath C:\vmware-tools.iso
    Remove-Item C:\vmware-tools.iso
    Write-Host "Done installing VMware Tools."
} elseif ($systemVendor -eq 'Parallels Software International Inc.') {
    Write-Host 'Installing the Parallels Tools for Guest VM...'
    foreach( $letter in 'DEFGHIJKLMNOPQRSTUVWXYZ'.ToCharArray() ) {
        $exe = "${letter}:\PTAgent.exe"
        if( Test-Path -LiteralPath $exe ) {
            Start-Process -FilePath $exe -ArgumentList '/install_silent' -Wait
            break
        } else {
            Write-Host 'Parallels Tools image (prl-tools-lin.iso) is not attached to this VM.'
        }
    }
    if ($LASTEXITCODE) {
        throw "failed to install Parallels Tools with exit code $LASTEXITCODE"
    }
    Write-Host "Done installing the Parallels Tools for Guest VM."
} else {
    Write-Host "Cannot install Guest Additions: Unsupported system ($systemVendor)."
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
