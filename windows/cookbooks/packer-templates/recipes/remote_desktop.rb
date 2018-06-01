dsc_resource "Enable RDP" do
  resource :xRemoteDesktopAdmin
  property :UserAuthentication, "Secure"
  property :ensure, "Present"
end

dsc_resource "Allow RDP firewall rule" do
  resource :xfirewall
  property :name, "Remote Desktop"
  property :ensure, "Present"
  property :enabled, "True"
end
