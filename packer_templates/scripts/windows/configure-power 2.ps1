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

Write-Host 'Set high performance power profile'
powercfg -setactive '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'

Write-Host 'Turn off Hibernation'
powercfg.exe /hibernate off

Write-Host 'Turn off monitor timeout on AC power'
powercfg -Change -monitor-timeout-ac 0

Write-Host 'Turn off monitor timeout on DC power'
powercfg -Change -monitor-timeout-dc 0

Write-Host 'Zero Hibernation File'
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -Name HiberFileSizePercent -Type DWORD -Value 0

Write-Host 'Disable Hibernation Mode'
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -Name HibernateEnabled -Type DWORD -Value 0
