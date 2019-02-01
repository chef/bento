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
  msu_package '2018-10 monthly rollup' do
    source 'http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/09/windows6.1-kb4462923-x64_5c4506692214692bf846da33052edb1dc5752156.msu'
    action :install
  end
end
