cmd /C cscript %TEMP%\wget.vbs /url:http://www.opscode.com/chef/install.msi /path:%TEMP%\chef-client.msi
cmd /C msiexec /qn /i %TEMP%\chef-client.msi
