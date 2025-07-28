os_name                 = "rockylinux"
os_version              = "10.0"
os_arch                 = "aarch64"
iso_url                 = "https://download.rockylinux.org/pub/rocky/9/isos/aarch64/Rocky-10.0-aarch64-boot.iso"
iso_checksum            = "file:https://download.rockylinux.org/pub/rocky/9/isos/aarch64/CHECKSUM"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "Oracle_arm64"
vmware_guest_os_type    = "arm-rhel9-64"
boot_command            = ["<wait><up>e<wait><down><down><end><wait> inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/10ks.cfg inst.repo=https://download.rockylinux.org/pub/rocky/10/BaseOS/aarch64/os/ <leftCtrlOn>x<leftCtrlOff>"]
