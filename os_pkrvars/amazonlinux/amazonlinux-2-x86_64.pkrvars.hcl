os_name            = "amazonlinux"
os_version         = "2"
os_arch            = "x86_64"
vbox_source_path   = "https://cdn.amazonlinux.com/os-images/latest/virtualbox/amzn2-virtualbox-2.0.20240306.2-x86_64.xfs.gpt.vdi"
vbox_checksum      = "file:https://cdn.amazonlinux.com/os-images/latest/virtualbox/SHA256SUMS"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "rhel9-64"
sources_enabled = [
  "source.virtualbox-ovf.vm"
]
