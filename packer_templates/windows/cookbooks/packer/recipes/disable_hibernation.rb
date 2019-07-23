registry_key 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power' do
  values [{ name: 'HiberFileSizePercent', type: :dword, data: 0 },
          { name: 'HibernateEnabled', type: :dword, data: 0 },
         ]
  action :create
end
