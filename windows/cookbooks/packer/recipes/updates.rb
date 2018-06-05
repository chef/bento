# Don't check for updates automatically. This needs to be configured before you can install updates
registry_key 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update' do
  values [{
    name: 'AUOptions',
    type: :dword,
    data: 1,
  }]
end

if node['platform_version'].to_f == 6.1 # 2008R2
  #
  # msu_package 'Powershell 3.0' do
  #   source 'https://download.microsoft.com/download/E/7/6/E76850B8-DA6E-4FF5-8CCE-A24FC513FD16/Windows6.1-KB2506143-x64.msu'
  #   action :install
  # end
  #

  msu_package '2018-05 monthly rollup' do
    source 'http://download.windowsupdate.com/d/msdownload/update/software/secu/2018/05/windows6.1-kb4103718-x64_c051268978faef39e21863a95ea2452ecbc0936d.msu'
    action :install
  end
end
