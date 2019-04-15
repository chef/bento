iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
C:/ProgramData/chocolatey/choco install habitat -y
New-NetFirewallRule -DisplayName \"Habitat TCP\" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 9631,9638
New-NetFirewallRule -DisplayName \"Habitat UDP\" -Direction Inbound -Action Allow -Protocol UDP -LocalPort 9638
C:\\ProgramData\\chocolatey\\bin\\hab pkg install core/windows-service
C:\\ProgramData\\chocolatey\\bin\\hab pkg exec core/windows-service install
C:\\ProgramData\\chocolatey\\bin\\hab pkg install core/hab-sup

Write-Host 'Installing Effortless Config Windows Baseline package'
C:\\ProgramData\\chocolatey\\bin\\hab pkg install effortless/config-baseline

Write-Host 'Installing Effortless Audit Windows Baseline package'
C:\\ProgramData\\chocolatey\\bin\\hab pkg install effortless/audit-baseline

$env:PATH = "$(hab pkg path stuartpreston/chef-client-detox)/bin;$(hab pkg path stuartpreston/inspec)/bin;$env:PATH"
cd (C:/ProgramData/chocolatey/bin/hab.exe pkg path effortless/config-baseline)
Write-Host 'Hardening and Patching OS with Effortless Config Linux Baseline package'
chef-client -z -c config/bootstrap-config.rb

Write-Host 'Verifying OS Compliance with Effortless Audit Linux Baseline package'
cd C:\\
inspec exec "$(hab pkg path effortless/audit-baseline)/dist" --no-distinct-exit --json-config "$(hab pkg path effortless/audit-baseline)\\config\\cli_only.json"
if($lastexitcode -ne 0) {Write-Output \"InSpec run failed check Automate for results\";exit 1}