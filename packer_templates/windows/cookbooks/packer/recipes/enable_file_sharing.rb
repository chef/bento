execute 'enable filesharing' do
  command 'netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes'
end
