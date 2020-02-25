# this causes onedrive to load then instantly exit
registry_key 'HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\OneDrive' do
  values [{ name: 'DisableFileSyncNGSC', type: :dword, data: 1 }]
  action :create
end
