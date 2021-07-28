# don't waste CPU / network bandwidth checking for updates
windows_update_settings 'disable windows update' do
  disable_automatic_updates true
end
