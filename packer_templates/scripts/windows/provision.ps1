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
    Exit 1
}

Write-Host 'Setting the vagrant account properties...'
if (-not (Get-LocalUser -Name "vagrant" -ErrorAction SilentlyContinue)) {
    net.exe user vagrant vagrant /add /expires:never
}
# see the ADS_USER_FLAG_ENUM enumeration at https://msdn.microsoft.com/en-us/library/aa772300(v=vs.85).aspx
$AdsScript              = 0x00001
$AdsAccountDisable      = 0x00002
$AdsNormalAccount       = 0x00200
$AdsDontExpirePassword  = 0x10000
$account = [ADSI]'WinNT://./vagrant'
$account.Userflags = $AdsNormalAccount -bor $AdsDontExpirePassword
$account.SetInfo()
net.exe localgroup Administrators vagrant /add

Write-Host 'Setting the Administrator account properties...'
$account = [ADSI]'WinNT://./Administrator'
$account.Userflags = $AdsNormalAccount -bor $AdsDontExpirePassword
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

function Write-SerialLog {
    param([string]$message)
    Write-Host $message
    try {
        cmd.exe /c "echo [WIN11-PROVISION] $message > COM1" 2>$null
    } catch { }
}

Write-SerialLog "Provisioning started..."

# Detect or normalize hypervisor builder type
$builderType = ""
if ($env:PACKER_BUILDER_TYPE) {
    $builderType = ($env:PACKER_BUILDER_TYPE -replace '\.vm$','').ToLower().Trim()
}

if (-not $builderType) {
    $bios = (Get-CimInstance Win32_BIOS -ErrorAction SilentlyContinue).Manufacturer
    $model = (Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue).Model
    if ($model -match 'VirtualBox' -or $bios -match 'innotek') {
        $builderType = "virtualbox-iso"
    } elseif ($model -match 'VMware') {
        $builderType = "vmware-iso"
    } elseif ($model -match 'KVM' -or $model -match 'QEMU' -or $bios -match 'QEMU' -or $bios -match 'EDK II') {
        $builderType = "qemu"
    } elseif ($model -match 'Virtual Machine') {
        $builderType = "hyperv-iso"
    } elseif ($model -match 'Parallels') {
        $builderType = "parallels-iso"
    } else {
        $builderType = "qemu"
    }
}

Write-SerialLog "Looking for Guest Tools for $builderType (raw: $env:PACKER_BUILDER_TYPE)..."
$volList = Get-Volume | Where-Object {$_.DriveType -ne 'Fixed' -and $_.DriveLetter}
switch -wildcard ($builderType) {
    "*virtualbox*" {
        # Actions for VirtualBox ISO builder
        $installed = $false
        foreach( $vol in $volList ) {
            $letter = $vol.DriveLetter
            $exe = "${letter}:\VBoxWindowsAdditions.exe"
            if( Test-Path -LiteralPath $exe ) {
                Write-SerialLog "Guest Tools found at $exe"
                try {
                    Write-Host 'Installing the VirtualBox Guest Additions...'
                    $certs = "${letter}:\cert"
                    Start-Process -FilePath "${certs}\VBoxCertUtil.exe" -ArgumentList "add-trusted-publisher ${certs}\vbox*.cer", "--root ${certs}\vbox*.cer"  -Wait -ErrorAction SilentlyContinue
                    Start-Process -FilePath $exe -ArgumentList '/with_wddm', '/S', '/noreboot' -Wait
                    $installed = $true
                    break
                }
                catch {
                    Write-Warning "Failed to install VirtualBox guest tools: $_"
                }
            } else {
                Write-Host "Guest Tools NOT FOUND at $exe"
            }
        }
        if ( $installed ) {
            Write-SerialLog "Done installing the guest tools."
        } else {
            Write-Warning "VirtualBox Guest Tools not found on mounted volumes. Continuing."
        }
        break
    }
    "*vmware*" {
        # Actions for VMware ISO builder
        $installed = $false
        $iso_mounted = $false

        # First, scan for the VMware Tools volume on an attached CD-ROM (attach mode, the default).
        $volList = Get-Volume | Where-Object {$_.FileSystemLabel -eq 'VMware Tools' -and $_.DriveLetter}

        if (-not $volList) {
            $iso_path = $null
            if (Test-Path -LiteralPath "C:\vmware-tools.iso") {
                $iso_path = "C:\vmware-tools.iso"
            } elseif (Test-Path -LiteralPath "C:\windows.iso") {
                $iso_path = "C:\windows.iso"
            }
            if ($iso_path) {
                Write-Host "VMware Tools not on an attached CD-ROM; mounting uploaded ISO at $iso_path..."
                Mount-DiskImage -ImagePath $iso_path -PassThru | Get-Volume
                $iso_mounted = $true
                $volList = Get-Volume | Where-Object {$_.FileSystemLabel -eq 'VMware Tools' -and $_.DriveLetter}
            }
        }

        foreach( $vol in $volList ) {
            $letter = $vol.DriveLetter
            $exe = "${letter}:\setup.exe"
            if( Test-Path -LiteralPath $exe ) {
                Write-SerialLog "Guest Tools found at $exe"
                try {
                    Write-Host 'Installing VMware Tools...'
                    Start-Process -FilePath $exe -ArgumentList '/S /v "/qn REBOOT=R"' -Wait
                    $installed = $true
                    break
                }
                catch {
                    Write-Warning "Failed to install VMware tools: $_"
                }
            } else {
                Write-Host "Guest Tools NOT FOUND at $exe"
            }
        }

        if ($iso_mounted) {
            Dismount-DiskImage -ImagePath $iso_path
            Remove-Item $iso_path -ErrorAction SilentlyContinue
        }

        if ( $installed ) {
            Write-SerialLog "Done installing VMware guest tools."
        } else {
            Write-Warning "VMware Guest Tools not found."
        }
        break
    }
    "*parallels*" {
        # Actions for Parallels ISO builder
        $installed = $false
        foreach( $vol in $volList ) {
            $letter = $vol.DriveLetter
            $exe = "${letter}:\PTAgent.exe"
            if( Test-Path -LiteralPath $exe ) {
                Write-SerialLog "Guest Tools found at $exe"
                try {
                    Write-Host 'Installing the Parallels Tools for Guest VM...'
                    Start-Process -FilePath $exe -ArgumentList '/install_silent' -Wait
                    $installed = $true
                    break
                }
                catch {
                    Write-Warning "Failed to install Parallels tools: $_"
                }
            } else {
                Write-Host "Guest Tools NOT FOUND at $exe"
            }
        }
        if ( $installed ) {
            Write-SerialLog "Done installing Parallels guest tools."
        } else {
            Write-Warning "Parallels Guest Tools not found."
        }
        break
    }
    { $_ -like "*utm*" -or $_ -like "*qemu*" } {
        # Actions for UTM and QEMU builder
        $installed = $false
        foreach( $vol in $volList ) {
            $letter = $vol.DriveLetter
            $exe = "${letter}:\virtio-win-guest-tools.exe"
            $arm64Inf = "${letter}:\NetKVM\w11\ARM64\netkvm.inf"

            if (Test-Path -LiteralPath $arm64Inf) {
                Write-Host "ARM64 VirtIO drivers found on ${letter}:\ - Installing via pnputil..."
                Get-ChildItem -Path "${letter}:\" -Filter "*.inf" -Recurse | Where-Object { $_.FullName -like "*ARM64*" } | ForEach-Object {
                    Write-Host "Installing driver: $($_.FullName)"
                    pnputil.exe /add-driver $_.FullName /install | Out-Null
                }
                $installed = $true
            }
            if (Test-Path -LiteralPath $exe) {
                Write-SerialLog "VirtIO Guest Tools found at $exe"
                try {
                    Write-Host 'Installing virtio guest tools...'
                    $p = Start-Process -FilePath $exe -ArgumentList '/qn', '/norestart' -PassThru
                    $p.WaitForExit(60000)
                    $installed = $true
                }
                catch {
                    Write-Warning "Failed to install VirtIO guest tools: $_"
                }
            }
            # Search for and install QEMU Guest Agent MSI if available (for quiesced snapshots via VSS)
            $isArm64 = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture -eq [System.Runtime.InteropServices.Architecture]::Arm64
            $gaPattern = if ($isArm64) { "*qemu-ga*arm64*.msi" } else { "*qemu-ga*x86_64*.msi" }
            $gaMsi = Get-ChildItem -Path "${letter}:\" -Filter $gaPattern -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if (-not $gaMsi) {
                $gaMsi = Get-ChildItem -Path "${letter}:\" -Filter "*qemu-ga*.msi" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            }
            if ($gaMsi) {
                Write-SerialLog "Installing QEMU Guest Agent from $($gaMsi.FullName)..."
                try {
                    $p = Start-Process msiexec.exe -ArgumentList "/i `"$($gaMsi.FullName)`" /qn /norestart" -Wait -PassThru
                    $p.WaitForExit(60000)
                    $installed = $true
                } catch {
                    Write-Warning "Failed to install QEMU Guest Agent MSI: $_"
                }
            }
            if ($installed) {
                break
            }
        }
        if ( $installed ) {
            Write-SerialLog "Done installing VirtIO guest tools and agent."
        } else {
            Write-Host "VirtIO drivers already present via unattend/cidata."
        }
        # Configure and start QEMU Guest Agent and Volume Shadow Copy (VSS) service for snapshot support
        try {
            if (Get-Service -Name "QEMU-GA" -ErrorAction SilentlyContinue) {
                Set-Service -Name "QEMU-GA" -StartupType Automatic
                Start-Service -Name "QEMU-GA" -ErrorAction SilentlyContinue
                Write-SerialLog "QEMU-GA service configured and running for live snapshots."
            }
        } catch {}
        try {
            Set-Service -Name "VSS" -StartupType Manual -ErrorAction SilentlyContinue
        } catch {}
        break
    }
    "*hyperv*" {
        # Actions for Hyper-V ISO builder
        Write-SerialLog "Hyper-V enlightenments already bundled with Windows."
        try {
            # Enable Hyper-V Volume Shadow Copy Requestor for consistent live snapshots
            Get-Service -Name "vmicvss" -ErrorAction SilentlyContinue | Set-Service -StartupType Automatic
            Start-Service -Name "vmicvss" -ErrorAction SilentlyContinue
            Write-SerialLog "Hyper-V Volume Shadow Copy Requestor configured for snapshots."
        } catch {}
        break
    }
    default {
        Write-Warning "Unrecognized PACKER_BUILDER_TYPE: $builderType. Proceeding without guest additions."
    }
}

# Install and configure OpenSSH Server for vagrant ssh
Write-Host "Configuring OpenSSH Server..."
$sshInstalled = $false
try {
    if (Get-Service -Name sshd -ErrorAction SilentlyContinue) {
        $sshInstalled = $true
    }
} catch {}

if (-not $sshInstalled) {
    Write-Host "Installing OpenSSH Server..."
    try {
        Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 -ErrorAction Stop
        $sshInstalled = $true
    } catch {
        Write-Host "Add-WindowsCapability failed ($_); attempting direct package download..."
        try {
            $isArm64 = [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture -eq [System.Runtime.InteropServices.Architecture]::Arm64
            $pkgName = if ($isArm64) { "OpenSSH-ARM64" } else { "OpenSSH-Win64" }
            $zipUrl = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/10.0.0.0p2-Preview/$pkgName.zip"
            $zipPath = "$env:TEMP\$pkgName.zip"
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
            Expand-Archive -Path $zipPath -DestinationPath "C:\Program Files" -Force
            if (Test-Path "C:\Program Files\$pkgName") {
                Rename-Item -Path "C:\Program Files\$pkgName" -NewName "OpenSSH" -Force
            }
            & "C:\Program Files\OpenSSH\install-sshd.ps1"
            [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\OpenSSH", [EnvironmentVariableTarget]::Machine)
            $sshInstalled = $true
        } catch {
            Write-Host "Warning: Could not install OpenSSH Server: $_"
        }
    }
}

if (Get-Service -Name sshd -ErrorAction SilentlyContinue) {
    Set-Service -Name sshd -StartupType 'Automatic'
    Start-Service sshd

    # Firewall rule
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 -ErrorAction SilentlyContinue

    # Set default shell to PowerShell
    New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force -ErrorAction SilentlyContinue

    # Configure Vagrant SSH public key
    Write-Host "Configuring Vagrant SSH keys..."
    $vagrantUserDir = "C:\Users\vagrant\.ssh"
    if (!(Test-Path -Path $vagrantUserDir)) {
        New-Item -ItemType Directory -Path $vagrantUserDir -Force | Out-Null
    }
    $pubKeyUrl = "https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub"
    $authKeysPath = "$vagrantUserDir\authorized_keys"
    $standardKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
    try {
        Invoke-WebRequest -Uri $pubKeyUrl -OutFile $authKeysPath -UseBasicParsing -TimeoutSec 10
    } catch {
        Write-Host "Failed to download Vagrant public key, writing standard insecure public key..."
        Set-Content -Path $authKeysPath -Value $standardKey -Encoding Ascii
    }

    # Set ACL on vagrant authorized_keys
    & icacls.exe $authKeysPath /inheritance:r /grant "Administrators:F" /grant "vagrant:F" /grant "SYSTEM:F" | Out-Null

    # Also setup administrators_authorized_keys
    $programDataSsh = "C:\ProgramData\ssh"
    if (!(Test-Path -Path $programDataSsh)) {
        New-Item -ItemType Directory -Path $programDataSsh -Force | Out-Null
    }
    $adminKeysPath = "$programDataSsh\administrators_authorized_keys"
    Copy-Item -Path $authKeysPath -Destination $adminKeysPath -Force
    & icacls.exe $adminKeysPath /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F" | Out-Null

    # Configure sshd_config for Vagrant compatibility
    $sshdConfig = "$programDataSsh\sshd_config"
    if (Test-Path $sshdConfig) {
        $content = Get-Content $sshdConfig
        $content = $content -replace '#PasswordAuthentication yes', 'PasswordAuthentication yes'
        $content = $content -replace 'Match Group administrators', '#Match Group administrators'
        $content = $content -replace 'AuthorizedKeysFile __PROGRAMDATA__', '#AuthorizedKeysFile __PROGRAMDATA__'
        $content = @("PubkeyAcceptedAlgorithms +ssh-rsa", "StrictModes no") + ($content | Where-Object { $_ -notmatch 'PubkeyAcceptedAlgorithms' -and $_ -notmatch 'StrictModes' })
        Set-Content $sshdConfig -Value $content
        Restart-Service sshd -ErrorAction SilentlyContinue
    }
}

# Enable Developer Mode so mklink (Vagrant synced folders) works without admin elevation
Write-Host "Enabling Developer Mode for symbolic links / synced folders..."
reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d 1 | Out-Null

# Enable File Sharing
Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing" -ErrorAction SilentlyContinue
Set-Service -Name LanmanServer -StartupType Automatic -ErrorAction SilentlyContinue
Start-Service LanmanServer -ErrorAction SilentlyContinue
Set-Service -Name LanmanWorkstation -StartupType Automatic -ErrorAction SilentlyContinue
Start-Service LanmanWorkstation -ErrorAction SilentlyContinue

# Install portable rsync for Vagrant synced folders
Write-Host "Configuring rsync for Vagrant synced folders..."
$rsyncDest = "C:\Windows\System32"
if (!(Get-Command rsync.exe -ErrorAction SilentlyContinue)) {
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $msysBase = "https://repo.msys2.org/msys/x86_64"
        $pkgs = @(
            "msys2-runtime-3.6.10-3-x86_64.pkg.tar.zst",
            "libiconv-1.18-1-x86_64.pkg.tar.zst",
            "liblz4-1.10.0-1-x86_64.pkg.tar.zst",
            "libxxhash-0.8.3-1-x86_64.pkg.tar.zst",
            "libzstd-1.5.7-1-x86_64.pkg.tar.zst",
            "libopenssl-3.4.1-1-x86_64.pkg.tar.zst",
            "rsync-3.4.1-1-x86_64.pkg.tar.zst"
        )
        $tmpDir = "$env:TEMP\rsync_setup"
        New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null
        foreach ($pkg in $pkgs) {
            Invoke-WebRequest -Uri "$msysBase/$pkg" -OutFile "$tmpDir\$pkg" -UseBasicParsing
            tar.exe -xf "$tmpDir\$pkg" -C "$tmpDir"
        }
        Get-ChildItem -Path "$tmpDir\usr\bin" -Include "rsync.exe","msys-*.dll" -Recurse | ForEach-Object {
            Copy-Item -Path $_.FullName -Destination $rsyncDest -Force
        }
        Remove-Item -Path $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "rsync installed successfully."
    } catch {
        Write-Host "Warning: Failed to install rsync: $_"
    }
}
