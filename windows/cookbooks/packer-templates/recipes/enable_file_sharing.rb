dsc_resource "File sharing firewall rule (SMB-In)" do
  resource :xfirewall
  property :name, "File and Printer Sharing (SMB-In)"
  property :ensure, "Present"
  property :enabled, "True"
end

dsc_resource "File sharing firewall rule (NB-Session-In)" do
  resource :xfirewall
  property :name, "File and Printer Sharing (NB-Session-In)"
  property :ensure, "Present"
  property :enabled, "True"
end
