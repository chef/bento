# don't bother saving data for a system restore
registry_key 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\SystemRestore' do
  values [{ name: 'DisableSR', type: :dword, data: 0 }] # disable
  action :create
end
