os_name                 = "almalinux"
os_version              = "9.2"
os_arch                 = "aarch64"
iso_url                 = "https://repo.almalinux.org/almalinux/9/isos/aarch64/AlmaLinux-9.2-aarch64-dvd.iso"
iso_checksum            = "file:https://repo.almalinux.org/almalinux/9/isos/aarch64/CHECKSUM"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "arm-rhel9-64"
boot_command            = ["<wait><up>e<wait><down><down><end><wait> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/9ks.cfg <leftCtrlOn>x<leftCtrlOff>"]
