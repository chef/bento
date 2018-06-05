windows_feature 'NetFx3' do
  action :install
  only_if { node['platform_version'].to_f == 6.1 }
end

windows_feature 'MicrosoftWindowsPowerShellISE' do
  action :remove
end
