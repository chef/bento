os_name                 = "centos-stream"
os_version              = "10"
os_arch                 = "aarch64"
iso_url                 = "https://mirror.stream.centos.org/10-stream/BaseOS/aarch64/iso/CentOS-Stream-10-latest-aarch64-dvd1.iso"
iso_checksum            = "file:https://mirror.stream.centos.org/10-stream/BaseOS/aarch64/iso/CentOS-Stream-10-latest-aarch64-dvd1.iso.SHA256SUM"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "arm-rhel9-64"
boot_command            = ["<wait><up>e<wait><down><down><end><wait> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/10ks.cfg <leftCtrlOn>x<leftCtrlOff>"]
