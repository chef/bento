Import-Module C:\windows\system32\windowspowershell\v1.0\Modules\Microsoft.PowerShell.Utility\Microsoft.PowerShell.Utility.psd1
Import-Module C:\windows\system32\windowspowershell\v1.0\Modules\Microsoft.PowerShell.Management\Microsoft.PowerShell.Management.psd1
Import-Module C:\windows\system32\windowspowershell\v1.0\Modules\Storage\Storage.psd1

$partition = Get-Partition -DriveLetter C
$c_size = $partition.size
$partition = Get-Partition -DriveLetter D
$d_size = $partition.size

Remove-Partition -DriveLetter D -Confirm:$false
Resize-Partition -DriveLetter C -Size ($c_size + $d_size)

Optimize-Volume -DriveLetter C

$FilePath="c:\zero.tmp"
$Volume= Get-Volume -DriveLetter C
$ArraySize= 64kb
$SpaceToLeave= $Volume.Size * 0.05
$FileSize= $Volume.SizeRemaining - $SpacetoLeave
$ZeroArray= new-object byte[]($ArraySize)
 
$Stream= [io.File]::OpenWrite($FilePath)
try {
   $CurFileSize = 0
    while($CurFileSize -lt $FileSize) {
        $Stream.Write($ZeroArray,0, $ZeroArray.Length)
        $CurFileSize +=$ZeroArray.Length
    }
} finally {
    if($Stream) {
        $Stream.Close()
    }
}
 
Del $FilePath

shutdown /s /t 0