node.default['windows']['feature_provider'] = 'dism'

windows_feature 'MicrosoftWindowsPowerShellISE' do
  action :remove
end
