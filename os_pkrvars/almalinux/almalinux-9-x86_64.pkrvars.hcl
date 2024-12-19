os_name                 = "almalinux"
os_version              = "9.5"
os_arch                 = "x86_64"
iso_url                 = "https://repo.almalinux.org/almalinux/9/isos/x86_64/AlmaLinux-9.5-x86_64-dvd.iso"
iso_checksum            = "file:https://repo.almalinux.org/almalinux/9/isos/x86_64/CHECKSUM"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<wait><wait><up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/9ks.cfg<enter><wait>"]
