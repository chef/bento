remote_file ::File.join(Chef::Config[:file_cache_path], 'ultradefrag.zip') do
  source 'http://downloads.sourceforge.net/ultradefrag/ultradefrag-portable-7.0.2.bin.amd64.zip'
  action :create
end

archive_file 'Decompress ultradefrag' do
  path ::File.join(Chef::Config[:file_cache_path], 'ultradefrag.zip')
  destination ::File.join(Chef::Config[:file_cache_path], 'temp_defrag')
  action :extract
end

execute 'Rename ultradefrag' do
  command "move #{::File.join(Chef::Config[:file_cache_path])}\\temp_defrag\\ultradefrag-* #{::File.join(Chef::Config[:file_cache_path], 'ultradefrag')}"
  not_if { ::File.exist?(::File.join(Chef::Config[:file_cache_path], 'ultradefrag')) }
end

execute 'Run ultradefrag' do
  command "#{::File.join(Chef::Config[:file_cache_path], 'ultradefrag', 'udefrag.exe')} --optimize --repeat %SystemDrive%"
  action :run
end
