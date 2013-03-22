cmd /C powershell (New-Object System.Net.Webclient).DownloadFile('http://http://www.opscode.com/chef/install.msi','c:\chef-client.msi')
cmd /C msiexec /qn /i c:\chef-client.msi
