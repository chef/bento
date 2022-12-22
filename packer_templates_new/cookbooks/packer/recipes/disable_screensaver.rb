# Disable the screensaver
registry_key 'HKEY_CURRENT_USER\Control Panel\Desktop' do
  values [{ name: 'ScreenSaveActive', type: :dword, data: 0 }] # disable
  action :create
end
