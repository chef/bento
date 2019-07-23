powershell_script 'disable-windows-defender' do
  code 'Set-MpPreference -DisableRealtimeMonitoring $false'
end
