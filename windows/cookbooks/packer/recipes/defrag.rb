remote_file ::File.join(Chef::Config[:file_cache_path], 'ultradefrag.zip') do
  source 'http://downloads.sourceforge.net/ultradefrag/ultradefrag-portable-7.0.2.bin.amd64.zip'
  action :create
end

windows_zipfile 'Decompress ultradefrag' do
  source ::File.join(Chef::Config[:file_cache_path], 'ultradefrag.zip')
  path ::File.join(Chef::Config[:file_cache_path])
  action :unzip
end

execute 'Rename ultradefrag' do
  command "move #{::File.join(Chef::Config[:file_cache_path])}\\ultradefrag-* #{::File.join(Chef::Config[:file_cache_path], 'ultradefrag')}"
  not_if { ::File.exist?(::File.join(Chef::Config[:file_cache_path], 'ultradefrag')) }
end

execute 'Run ultradefrag' do
  command "#{::File.join(Chef::Config[:file_cache_path], 'ultradefrag', 'udefrag.exe')} --optimize --repeat %SystemDrive%"
  action :run
end
