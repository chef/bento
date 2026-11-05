os_name                 = "omnios"
os_version              = "r151054"
os_arch                 = "x86_64"
iso_url                 = "https://downloads.omnios.org/media/r151054/omnios-r151054r.iso"
iso_checksum            = "sha256:f91796378671640fb253bfc431d335d59cdc6ed698abbc6da16148921b0a7a83"
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
