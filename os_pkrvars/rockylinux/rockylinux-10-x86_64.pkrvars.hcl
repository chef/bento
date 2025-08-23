os_name                 = "rockylinux"
os_version              = "10.0"
os_arch                 = "x86_64"
iso_url                 = "https://download.rockylinux.org/pub/rocky/10/isos/x86_64/Rocky-10.0-x86_64-boot.iso"
iso_checksum            = "file:https://download.rockylinux.org/pub/rocky/10/isos/x86_64/CHECKSUM"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "Oracle_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<wait><up>e<wait><down><down><end><wait> inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/ks.cfg inst.repo=https://download.rockylinux.org/pub/rocky/10/BaseOS/x86_64/os/ <leftCtrlOn>x<leftCtrlOff>"]
