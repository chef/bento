powershell_script 'lots of stuff' do
  code <<-EOH
    $ErrorActionPreference = "Stop"
    . a:/Test-Command.ps1

    Write-Host "Enabling file sharing firewall rules"
    netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=yes

    if(Test-Path "C:/Users/vagrant/VBoxGuestAdditions.iso") {
        Write-Host "Installing Guest Additions"
        certutil -addstore -f "TrustedPublisher" A:/oracle.cer
        cinst 7zip.commandline -y
        Move-Item C:/Users/vagrant/VBoxGuestAdditions.iso C:/Windows/Temp
        ."C:/ProgramData/chocolatey/lib/7zip.commandline/tools/7z.exe" x C:/Windows/Temp/VBoxGuestAdditions.iso -oC:/Windows/Temp/virtualbox

        Start-Process -FilePath "C:/Windows/Temp/virtualbox/VBoxWindowsAdditions.exe" -ArgumentList "/S" -WorkingDirectory "C:/Windows/Temp/virtualbox" -Wait

        Remove-Item C:/Windows/Temp/virtualbox -Recurse -Force
        Remove-Item C:/Windows/Temp/VBoxGuestAdditions.iso -Force
    }

    Write-Host "Cleaning SxS..."
    Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

    @(
        "$env:localappdata/Nuget",
        "$env:localappdata/temp/*",
        "$env:windir/logs",
        "$env:windir/panther",
        "$env:windir/temp/*",
        "$env:windir/winsxs/manifestcache"
    ) | % {
            if(Test-Path $_) {
                Write-Host "Removing $_"
                try {
                  Takeown /d Y /R /f $_
                  Icacls $_ /GRANT:r administrators:F /T /c /q  2>&1 | Out-Null
                  Remove-Item $_ -Recurse -Force | Out-Null
                } catch { $global:error.RemoveAt(0) }
            }
        }

    Write-Host "defragging..."
    if (Test-Command -cmdname 'Optimize-Volume') {
        Optimize-Volume -DriveLetter C
        } else {
        Defrag.exe c: /H
    }

    Write-Host "0ing out empty space..."
    $FilePath="c:/zero.tmp"
    $Volume = Get-WmiObject win32_logicaldisk -filter "DeviceID='C:'"
    $ArraySize= 64kb
    $SpaceToLeave= $Volume.Size * 0.05
    $FileSize= $Volume.FreeSpace - $SpacetoLeave
    $ZeroArray= new-object byte[]($ArraySize)

    $Stream= [io.File]::OpenWrite($FilePath)
    try {
       $CurFileSize = 0
        while($CurFileSize -lt $FileSize) {
            $Stream.Write($ZeroArray,0, $ZeroArray.Length)
            $CurFileSize +=$ZeroArray.Length
        }
    }
    finally {
        if($Stream) {
            $Stream.Close()
        }
    }

    Del $FilePath

    Write-Host "copying auto unattend file"
    mkdir C:/Windows/setup/scripts
    copy-item a:/SetupComplete-2012.cmd C:/Windows/setup/scripts/SetupComplete.cmd -Force

    mkdir C:/Windows/Panther/Unattend
    copy-item a:/postunattend.xml C:/Windows/Panther/Unattend/unattend.xml

    Write-Host "Recreate pagefile after sysprep"
    $System = GWMI Win32_ComputerSystem -EnableAllPrivileges
    if ($system -ne $null) {
      $System.AutomaticManagedPagefile = $true
      $System.Put()
    }
  EOH
end
