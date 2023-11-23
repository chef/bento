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

Write-Host 'Removing OneDrive'
function force-mkdir($path) {
    if (!(Test-Path $path)) {
        #Write-Host "-- Creating full path to: " $path -ForegroundColor White -BackgroundColor DarkGreen
        New-Item -ItemType Directory -Force -Path $path
    }}

function Takeown-Registry($key) {
    # TODO does not work for all root keys yet
    switch ($key.split('\')[0]) {
        "HKEY_CLASSES_ROOT" {
            $reg = [Microsoft.Win32.Registry]::ClassesRoot
            $key = $key.substring(18)
        }
        "HKEY_CURRENT_USER" {
            $reg = [Microsoft.Win32.Registry]::CurrentUser
            $key = $key.substring(18)
        }
        "HKEY_LOCAL_MACHINE" {
            $reg = [Microsoft.Win32.Registry]::LocalMachine
            $key = $key.substring(19)
        }
    }

    # get administraor group
    $admins = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
    $admins = $admins.Translate([System.Security.Principal.NTAccount])

    # set owner
    $key = $reg.OpenSubKey($key, "ReadWriteSubTree", "TakeOwnership")
    $acl = $key.GetAccessControl()
    $acl.SetOwner($admins)
    $key.SetAccessControl($acl)

    # set FullControl
    $acl = $key.GetAccessControl()
    $rule = New-Object System.Security.AccessControl.RegistryAccessRule($admins, "FullControl", "Allow")
    $acl.SetAccessRule($rule)
    $key.SetAccessControl($acl)
}

function Takeown-File($path) {
    takeown.exe /A /F $path
    $acl = Get-Acl $path

    # get administraor group
    $admins = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
    $admins = $admins.Translate([System.Security.Principal.NTAccount])

    # add NT Authority\SYSTEM
    $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($admins, "FullControl", "None", "None", "Allow")
    $acl.AddAccessRule($rule)

    Set-Acl -Path $path -AclObject $acl
}

function Takeown-Folder($path) {
    Takeown-File $path
    foreach ($item in Get-ChildItem $path) {
        if (Test-Path $item -PathType Container) {
            Takeown-Folder $item.FullName
        } else {
            Takeown-File $item.FullName
        }
    }
}

function Elevate-Privileges {
    param($Privilege)
    $Definition = @"
    using System;
    using System.Runtime.InteropServices;
    public class AdjPriv {
        [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
            internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall, ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr rele);
        [DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
            internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr phtok);
        [DllImport("advapi32.dll", SetLastError = true)]
            internal static extern bool LookupPrivilegeValue(string host, string name, ref long pluid);
        [StructLayout(LayoutKind.Sequential, Pack = 1)]
            internal struct TokPriv1Luid {
                public int Count;
                public long Luid;
                public int Attr;
            }
        internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
        internal const int TOKEN_QUERY = 0x00000008;
        internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;
        public static bool EnablePrivilege(long processHandle, string privilege) {
            bool retVal;
            TokPriv1Luid tp;
            IntPtr hproc = new IntPtr(processHandle);
            IntPtr htok = IntPtr.Zero;
            retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
            tp.Count = 1;
            tp.Luid = 0;
            tp.Attr = SE_PRIVILEGE_ENABLED;
            retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
            retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
            return retVal;
        }
    }
"@
    $ProcessHandle = (Get-Process -id $pid).Handle
    $type = Add-Type $definition -PassThru
    $type[0]::EnablePrivilege($processHandle, $Privilege)
}

Write-Host "73 OneDrive process and explorer"
taskkill.exe /F /IM "OneDrive.exe"
taskkill.exe /F /IM "explorer.exe"

Write-Host "Remove OneDrive"
if (Test-Path "$env:systemroot\System32\OneDriveSetup.exe") {
    & "$env:systemroot\System32\OneDriveSetup.exe" /uninstall
}
if (Test-Path "$env:systemroot\SysWOW64\OneDriveSetup.exe") {
    & "$env:systemroot\SysWOW64\OneDriveSetup.exe" /uninstall
}

Write-Host "Disable OneDrive via Group Policies"
force-mkdir "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive"
Set-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive" -Name DisableFileSyncNGSC -Value 1

Write-Host "Removing OneDrive leftovers trash"
rm -Recurse -Force -ErrorAction SilentlyContinue "$env:localappdata\Microsoft\OneDrive"
rm -Recurse -Force -ErrorAction SilentlyContinue "$env:programdata\Microsoft OneDrive"
rm -Recurse -Force -ErrorAction SilentlyContinue "C:\OneDriveTemp"

Write-Host "Remove Onedrive from explorer sidebar"
New-PSDrive -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" -Name "HKCR"
mkdir -Force "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
Set-ItemProperty "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name System.IsPinnedToNameSpaceTree -Value 0
mkdir -Force "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
Set-ItemProperty "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name System.IsPinnedToNameSpaceTree -Value 0
Remove-PSDrive "HKCR"

Write-Host "Removing run option for new users"
reg load "hku\Default" "C:\Users\Default\NTUSER.DAT"
reg delete "HKEY_USERS\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f
reg unload "hku\Default"

Write-Host "Removing startmenu junk entry"
rm -Force -ErrorAction SilentlyContinue "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"

Write-Host "Restarting explorer..."
start "explorer.exe"

Write-Host "Wait for EX reload.."
sleep 15

Write-Host "Removing additional OneDrive leftovers"
foreach ($item in (ls "$env:WinDir\WinSxS\*onedrive*")) {
    Takeown-Folder $item.FullName
    rm -Recurse -Force $item.FullName -ErrorAction SilentlyContinue
}

###########################################################################################
Write-Host "Removing Teams"
# Clearing Teams Cache by Mark Vale
# Uninstall Teams by Rudy Mens

Write-Host "Stopping Teams Process" -ForegroundColor Yellow
try{
    Get-Process -ProcessName Teams | Stop-Process -Force
    Start-Sleep -Seconds 3
    Write-Host "Teams Process Sucessfully Stopped" -ForegroundColor Green
}catch{
    Write-Host $_
}

Write-Host "Clearing Teams Disk Cache" -ForegroundColor Yellow
try{
    Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\application cache\cache" | Remove-Item -Confirm:$false
    Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\blob_storage" | Remove-Item -Confirm:$false
    Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\databases" | Remove-Item -Confirm:$false
    Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\cache" | Remove-Item -Confirm:$false
    Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\gpucache" | Remove-Item -Confirm:$false
    Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\Indexeddb" | Remove-Item -Confirm:$false
    Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\Local Storage" | Remove-Item -Confirm:$false
    Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\tmp" | Remove-Item -Confirm:$false
    Write-Host "Teams Disk Cache Cleaned" -ForegroundColor Green
}catch{
    Write-Host $_
}

Write-Host "Stopping IE Process" -ForegroundColor Yellow
try{
    Get-Process -ProcessName MicrosoftEdge | Stop-Process -Force
    Get-Process -ProcessName IExplore | Stop-Process -Force
    Write-Host "Internet Explorer and Edge Processes Sucessfully Stopped" -ForegroundColor Green
}catch{
    Write-Host $_
}

Write-Host "Clearing IE Cache" -ForegroundColor Yellow
try{
    RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 8
    RunDll32.exe InetCpl.cpl, ClearMyTracksByProcess 2
    Write-Host "IE and Edge Cleaned" -ForegroundColor Green
}catch{
    Write-Host $_
}
Write-Host "Cleanup Complete..."


Write-Host "Removing Teams Machine-wide Installer"
try
{
    $MachineWide = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "Teams Machine-Wide Installer"}
    $MachineWide.Uninstall()
}
catch
{
    Write-Warning $_
}

function unInstallTeams($path) {
    $clientInstaller = "$($path)\Update.exe"
    try {
        $process = Start-Process -FilePath "$clientInstaller" -ArgumentList "--uninstall /s" -PassThru -Wait -ErrorAction STOP
        if ($process.ExitCode -ne 0)
        {
            Write-Warning "UnInstallation failed with exit code  $($process.ExitCode)."
        }
    }
    catch {
        Write-Warning $_.Exception.Message
    }
}

#Locate installation folder
$localAppData = "$($env:LOCALAPPDATA)\Microsoft\Teams"
$programData = "$($env:ProgramData)\$($env:USERNAME)\Microsoft\Teams"

If (Test-Path "$($localAppData)\Current\Teams.exe")
{
    unInstallTeams($localAppData)
}
elseif (Test-Path "$($programData)\Current\Teams.exe") {
    unInstallTeams($programData)
}
else {
    Write-Warning  "Teams installation not found"
}
