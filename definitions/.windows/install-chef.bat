timeout 10
REM sleeping to give outbound networking a chance to come up
cmd /C cscript %TEMP%\wget.vbs /url:http://www.opscode.com/chef/install.msi /path:chef-client.msi
cmd /C msiexec /qn /i chef-client.msi


