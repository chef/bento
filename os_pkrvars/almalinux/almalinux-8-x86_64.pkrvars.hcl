os_name                 = "almalinux"
os_version              = "8.10"
os_arch                 = "x86_64"
iso_url                 = "https://repo.almalinux.org/almalinux/8/isos/x86_64/AlmaLinux-8.10-x86_64-minimal.iso"
iso_checksum            = "file:https://repo.almalinux.org/almalinux/8/isos/x86_64/CHECKSUM"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<wait><up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/8ks.cfg<enter><wait>"]
