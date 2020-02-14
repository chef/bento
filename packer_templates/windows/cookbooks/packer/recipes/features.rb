windows_feature 'NetFx3' do
  action :install
  only_if { windows_nt_version == 6.1 }
end

windows_feature 'MicrosoftWindowsPowerShellISE' do
  action :remove
end
