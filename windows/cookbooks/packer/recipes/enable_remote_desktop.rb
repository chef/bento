execute 'Enable RDP' do
  command 'reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f'
end

execute 'Enable RDP firewall rule' do
  command 'netsh advfirewall firewall set rule group="Remote Desktop" new enable=Yes'
end
