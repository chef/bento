os_name                 = "omnios"
os_version              = "r151058"
os_arch                 = "x86_64"
iso_url                 = "https://downloads.omnios.org/media/stable/omnios-r151058.iso"
iso_checksum            = "sha256:13ea7c4950ceddba969599893fca3aaaee98c07f7952529143111d18cc4a25d3"
parallels_guest_os_type = "solaris"
vbox_guest_os_type      = "OpenSolaris_64"
vmware_guest_os_type    = "solaris11-64"
utm_vm_icon             = "solaris"
default_boot_wait       = "10s"
boot_command = [
  "7<wait5>",
  "set kayak_config=http://{{ .HTTPIP }}:{{ .HTTPPort }}/omnios/kayak.cfg<enter><wait>",
  "boot<enter>"
]
ssh_username     = "vagrant"
ssh_password     = "vagrant"
ssh_port         = 22
ssh_timeout      = "30m"
shutdown_command = "sudo /sbin/init 5"
