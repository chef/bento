os_name                 = "springdalelinux"
os_version              = "7.9"
os_arch                 = "x86_64"
iso_url                 = "http://springdale.princeton.edu/data/springdale/7/x86_64/iso/Springdale%20Linux-7.9-x86_64-netinst.iso"
iso_checksum            = "ad47807e17f796bdca35bb3ec5b65f1340d43b698ee04dcf60faecc8c6818c67"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/springdalelinux/7ks.cfg<enter><wait>"]
boot_command_hyperv     = ["<wait5><up><wait5><tab> text ks=hd:fd0:/ks.cfg<enter><wait5><esc>"]
