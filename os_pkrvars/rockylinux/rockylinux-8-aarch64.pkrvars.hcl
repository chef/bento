os_name                 = "rockylinux"
os_version              = "8.10"
os_arch                 = "aarch64"
iso_url                 = "https://download.rockylinux.org/pub/rocky/8/isos/aarch64/Rocky-8.10-aarch64-boot.iso"
iso_checksum            = "file:https://download.rockylinux.org/pub/rocky/8/isos/aarch64/CHECKSUM"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "Oracle_arm64"
vmware_guest_os_type    = "arm-rhel9-64"
boot_command            = ["<wait><up>e<wait><down><down><end><wait> inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/8ks.cfg inst.repo=https://download.rockylinux.org/pub/rocky/8/BaseOS/aarch64/os/ <leftCtrlOn>x<leftCtrlOff>"]
