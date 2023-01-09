os_name                 = "almalinux"
os_version              = "8.7"
os_arch                 = "x86_64"
iso_url                 = "https://repo.almalinux.org/almalinux/8.7/isos/x86_64/AlmaLinux-8.7-x86_64-dvd.iso"
iso_checksum            = "b95ddf9d56a849cc8eb4b95dd2321c13af637d3379b91f5d96c39e96fb4403b3"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/8ks.cfg<enter><wait>"]
boot_command_hyperv     = ["<wait5><up><wait5><tab> text ks=hd:fd0:/ks.cfg<enter><wait5><esc>"]
