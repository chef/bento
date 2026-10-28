Set-StrictMode -Version Latest
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

trap {
    Write-Host
    Write-Host "ERROR: $_"
    ($_.ScriptStackTrace -split '?
') -replace '^(.*)$','ERROR: $1' | Write-Host
    ($_.Exception.ToString() -split '?
') -replace '^(.*)$','ERROR EXCEPTION: $1' | Write-Host
    Write-Host
    Exit 1
}

# Enable TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

Write-Host "Deleting residual pagefile and swapfile..."
try {
    Remove-Item -Path "C:\pagefile.sys" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\swapfile.sys" -Force -ErrorAction SilentlyContinue
} catch { }

Write-Host "Enabling CompactOS compression on system binaries..."
try {
    compact.exe /compactOS:always
} catch {
    Write-Host "CompactOS warning: $_"
}

Write-Host "Compressing static program and system directories using LZX..."
@(
    "C:\Program Files",
    "C:\Program Files (x86)",
    "C:\ProgramData",
    "C:\Windows\System32\DriverStore\FileRepository",
    "C:\Windows\System32\WindowsPowerShell",
    "C:\Windows\Microsoft.NET",
    "C:\Windows\Inf",
    "C:\Windows\Fonts",
    "C:\Windows\WinSxS"
) | ForEach-Object {
    if (Test-Path $_) {
        try {
            compact.exe /c /s /a /i /exe:lzx "$_\*" 2>$null
        } catch { }
    }
}

Write-Host "Disabling Hibernation to remove hiberfil.sys..."
try {
    powercfg.exe /hibernate off
} catch { }

Write-Host "Deleting Volume Shadow Copies..."
try {
    vssadmin.exe delete shadows /all /quiet 2>$null
} catch { }

Write-Host "Disabling System Restore..."
try {
    Disable-ComputerRestore -Drive "C:" -ErrorAction SilentlyContinue
} catch { }

Write-Host "Purging Recycle Bin and DNS cache..."
try {
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Clear-DnsClientCache -ErrorAction SilentlyContinue
} catch { }

Write-Host "Optimizing and defragmenting volume..."
try {
    Optimize-Volume -DriveLetter C -Defrag -Verbose
} catch {
    Write-Host "Defrag warning: $_"
}

Write-Host "Zeroing free disk space for maximum box compression..."
$sdeleteDownloaded = $false
try {
    Write-Host "Downloading SDelete64a (ARM64) from Sysinternals..."
    Invoke-WebRequest -Uri "https://live.sysinternals.com/sdelete64a.exe" -OutFile "$env:TEMP\sdelete.exe" -UseBasicParsing -ErrorAction Stop
    $sdeleteDownloaded = $true
} catch {
    Write-Host "Failed to download SDelete: $_"
}

if ($sdeleteDownloaded) {
    try {
        Write-Host "Running SDelete to zero free space and MFT..."
        Start-Process -FilePath "$env:TEMP\sdelete.exe" -ArgumentList "-z", "-accepteula", "C:" -Wait -NoNewWindow
    } catch {
        Write-Host "SDelete failed, falling back to manual zeroing."
        $sdeleteDownloaded = $false
    }
}

if (-not $sdeleteDownloaded) {
    $FilePath = "C:\zero.tmp"
    $ArraySize = 4MB
    $ZeroArray = [byte[]]::new($ArraySize)

    try {
        $Stream = [System.IO.File]::OpenWrite($FilePath)
        try {
            while ($true) {
                $Stream.Write($ZeroArray, 0, $ZeroArray.Length)
            }
        } catch [System.IO.IOException] {
            # Disk full reached - expected
            Write-Host "Free disk space successfully filled with zeroes."
        } finally {
            if ($Stream) {
                $Stream.Flush()
                $Stream.Close()
                $Stream.Dispose()
            }
        }
    } catch {
        Write-Host "Zeroing caught error: $_"
    } finally {
        if (Test-Path $FilePath) {
            Remove-Item -Force $FilePath -ErrorAction SilentlyContinue
        }
    }
}

Write-Host "ReTrimming Drive to unmap zeroed free blocks at hypervisor level..."
try {
    Optimize-Volume -DriveLetter C -ReTrim -Verbose -ErrorAction SilentlyContinue
} catch {
    Write-Host "ReTrim warning: $_"
}

Write-Host "Disk optimization complete."
exit 0
