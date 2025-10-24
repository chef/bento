os_name                 = "rockylinux"
os_version              = "8.10"
os_arch                 = "x86_64"
iso_url                 = "https://download.rockylinux.org/pub/rocky/8/isos/x86_64/Rocky-8.10-x86_64-boot.iso"
iso_checksum            = "file:https://download.rockylinux.org/pub/rocky/8/isos/x86_64/CHECKSUM"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "Oracle_64"
vmware_guest_os_type    = "centos-64"
utm_vm_icon             = "linux"
boot_command            = ["<wait><up><tab><wait><end><wait> inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/8ks.cfg inst.repo=https://download.rockylinux.org/pub/rocky/8/BaseOS/x86_64/os/ <wait><enter><wait>"]
utm_boot_command        = ["<wait><up>e<wait><down><down><end><wait> inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/8ks.cfg inst.repo=https://download.rockylinux.org/pub/rocky/8/BaseOS/x86_64/os/ <wait><leftCtrlOn><wait>x<wait><leftCtrlOff>"]
