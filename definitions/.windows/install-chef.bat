timeout 10
REM sleeping to give outbound networkingh a chance to come up
cmd /C cscript wget.vbs /url:http://10.12.13.1/chef-client-11.4.0-18-gdf096fa-1.windows.msi /path:chef-client.msi
cmd /C msiexec /qn /i chef-client.msi
timeout 120

