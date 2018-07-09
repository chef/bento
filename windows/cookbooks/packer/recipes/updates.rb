# Don't check for updates automatically. This needs to be configured before you can install updates
registry_key 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update' do
  values [{
    name: 'AUOptions',
    type: :dword,
    data: 1,
  }]
end

if node['platform_version'].to_f == 6.1 # 2008R2

  # This is basically a service pack and we should install it to fix a giant pile of bugs
  msu_package '2018-06 monthly rollup' do
    source 'http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/06/windows6.1-kb4284826-x64_9e172f5bb50206dd65d4f60ac07a82baa1aef525.msu'
    action :install
  end
end
