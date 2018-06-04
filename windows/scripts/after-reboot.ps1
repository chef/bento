$ProgressPreference='SilentlyContinue'
Get-WUInstall -WindowsUpdate -AcceptAll -UpdateType Software -IgnoreReboot

# The sleeps may seem whacky because they are
# Might be able to remove after 2016 RTMs
# For now after much trial and error, this is what works
Write-Host "waiting 5 minutes"
Start-Sleep -Seconds 300

$uninstallSuccess = $false
while(!$uninstallSuccess) {
  Write-Host "Attempting to uninstall features..."
  try {
    Get-WindowsFeature | ? { $_.InstallState -eq 'Available' } | Uninstall-WindowsFeature -Remove -ErrorAction Stop
    Write-Host "Uninstall succeeded!"
    $uninstallSuccess = $true
  }
  catch {
    Write-Host "Waiting two minutes before next attempt"
    Start-Sleep -Seconds 120
  }
}
