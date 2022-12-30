os_name                 = "almalinux"
os_version              = "8.7"
os_arch                 = "aarch64"
iso_url                 = "https://seattle.crazyfast.us/almalinux/8.7/isos/aarch64/AlmaLinux-8.7-aarch64-dvd.iso"
iso_checksum            = "c14fae79d5e26bc41e75f0a65063ab684199a7ea3a6bd0a8086e1ffd2a7afac8"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<up>e<wait><down><down><end><wait> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/8ks.cfg<leftCtrlOn>x<leftCtrlOff>"]
boot_command_hyperv     = ["<wait5><up><wait5><tab> text ks=hd:fd0:/ks.cfg<enter><wait5><esc>"]
