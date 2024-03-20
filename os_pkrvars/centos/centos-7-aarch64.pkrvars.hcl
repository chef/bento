os_name                 = "centos"
os_version              = "7.9"
os_arch                 = "aarch64"
iso_url                 = "https://quantum-mirror.hu/mirrors/pub/centos-altarch/7.9.2009/isos/aarch64/CentOS-7-aarch64-Minimal-2009.iso"
iso_checksum            = "file:https://quantum-mirror.hu/mirrors/pub/centos-altarch/7.9.2009/isos/aarch64/sha256sum.txt"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "arm-other-64"
boot_command            = ["<wait><up>e<wait><down><down><end><wait> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/7ks.cfg <leftCtrlOn>x<leftCtrlOff>"]
