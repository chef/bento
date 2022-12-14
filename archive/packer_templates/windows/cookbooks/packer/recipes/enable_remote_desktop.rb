registry_key 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server' do
  values [{
    name: 'fDenyTSConnections',
    type: :dword,
    data: 0 }]
end

execute 'Enable RDP firewall rule' do
  command 'netsh advfirewall firewall set rule group="Remote Desktop" new enable=Yes'
end
