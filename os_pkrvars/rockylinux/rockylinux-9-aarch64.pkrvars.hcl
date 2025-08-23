os_name                 = "rockylinux"
os_version              = "9.6"
os_arch                 = "aarch64"
iso_url                 = "https://download.rockylinux.org/pub/rocky/9/isos/aarch64/Rocky-9.6-aarch64-boot.iso"
iso_checksum            = "file:https://download.rockylinux.org/pub/rocky/9/isos/aarch64/CHECKSUM"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "Oracle9_arm64"
vmware_guest_os_type    = "arm-rhel9-64"
boot_command            = ["<wait><up>e<wait><down><down><end><wait> inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/ks.cfg inst.repo=https://download.rockylinux.org/pub/rocky/9/BaseOS/aarch64/os/ <leftCtrlOn>x<leftCtrlOff>"]
