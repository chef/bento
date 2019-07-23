# don't waste CPU / network bandwidth checking for updates
registry_key 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' do
  values [{ name: 'AUOptions', type: :dword, data: 1 }, # disable keep my computer up to date
          { name: 'NoAutoUpdate', type: :dword, data: 1 }, # disable auto updates
         ]
  action :create
  recursive true
end
