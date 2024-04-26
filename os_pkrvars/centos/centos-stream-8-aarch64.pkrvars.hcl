os_name                 = "centos-stream"
os_version              = "8"
os_arch                 = "aarch64"
iso_url                 = "https://mirrors.edge.kernel.org/centos/8-stream/isos/aarch64/CentOS-Stream-8-aarch64-latest-boot.iso"
iso_checksum            = "file:https://mirrors.edge.kernel.org/centos/8-stream/isos/aarch64/CHECKSUM"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "arm-other-64"
boot_command            = ["<wait><up>e<wait><down><down><end><wait> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/8ks.cfg <leftCtrlOn>x<leftCtrlOff>"]
