if windows_nt_version == '10.0.17763' # 2019
  # This is basically a service pack and we should install it to fix a giant pile of bugs
  msu_package '2020-04 monthly rollup' do
    source 'http://download.windowsupdate.com/d/msdownload/update/software/updt/2020/04/windows10.0-kb4550969-x64_7d0a6efbe9e4d44253babdc161873513f88fc1e4.msu'
    action :install
  end
elsif windows_nt_version == '10.0.14393' # 2016
  # This is basically a service pack and we should install it to fix a giant pile of bugs
  msu_package '2020-04 monthly rollup' do
    source 'http://download.windowsupdate.com/d/msdownload/update/software/updt/2020/04/windows10.0-kb4550947-x64_f2ec932f8fb2be82d2f430b5dcd1ec4b92a7611c.msu'
    action :install
  end
end
