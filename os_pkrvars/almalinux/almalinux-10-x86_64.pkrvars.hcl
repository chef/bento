os_name                 = "almalinux"
os_version              = "10.0"
os_arch                 = "x86_64"
iso_url                 = "https://repo.almalinux.org/almalinux/10/isos/x86_64/AlmaLinux-10.0-x86_64-boot.iso"
iso_checksum            = "file:https://repo.almalinux.org/almalinux/10/isos/x86_64/CHECKSUM"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<wait><up><wait>e<wait><down><wait><down><wait><end><wait> inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/ks.cfg inst.repo=https://repo.almalinux.org/almalinux/10/BaseOS/x86_64/os/ <leftCtrlOn>x<leftCtrlOff>"]
