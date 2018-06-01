# On first boot, the WinRM and other services are starting
# and stopping and restarting and somewhere in the middle of
# all of that vagrant finds that WinRM is accessible but
# something is shutdown in the middle of its connection attempt
# sometimes resulting in an error.
 
# To work around this we disable the WinRM firewall in the
# shutdown command and turn it back on in SetupComplete.cmd
# file. This way while the box is going through its first boot
# cycles of restarting services, it cant get to WinRM.
# Then once its fully up it runs SetupComplete and the WinRM
# port is made accessible.

directory "C:/Windows/setup/scripts" do
  recursive true
end

file "restart winmgmt on first boot" do
  content "netsh advfirewall firewall set rule name=\"WinRM-HTTP\" new action=allow"
  path "C:/Windows/setup/scripts/SetupComplete.cmd"
end
