os_name                 = "centos-stream"
os_version              = "10"
os_arch                 = "x86_64"
iso_url                 = "https://mirror.stream.centos.org/10-stream/BaseOS/x86_64/iso/CentOS-Stream-10-latest-x86_64-boot.iso"
iso_checksum            = "file:https://mirror.stream.centos.org/10-stream/BaseOS/x86_64/iso/CentOS-Stream-10-latest-x86_64-boot.iso.SHA256SUM"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<wait><up>e<wait><down><down><end><wait> inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/ks.cfg inst.repo=https://mirror.stream.centos.org/10-stream/BaseOS/x86_64/os/ <leftCtrlOn>x<leftCtrlOff><wait>"]
