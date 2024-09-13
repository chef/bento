os_name                 = "almalinux"
os_version              = "8.10"
os_arch                 = "aarch64"
iso_url                 = "https://repo.almalinux.org/almalinux/8/isos/aarch64/AlmaLinux-8.10-aarch64-minimal.iso"
iso_checksum            = "file:https://repo.almalinux.org/almalinux/8/isos/aarch64/CHECKSUM"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "arm-centos-64"
boot_command            = ["<wait><up>e<wait><down><down><end><wait> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/8ks.cfg <leftCtrlOn>x<leftCtrlOff>"]
