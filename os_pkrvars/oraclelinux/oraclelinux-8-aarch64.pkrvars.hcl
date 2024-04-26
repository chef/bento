os_name                 = "oraclelinux"
os_version              = "8.9"
os_arch                 = "aarch64"
iso_url                 = "https://yum.oracle.com/ISOS/OracleLinux/OL8/u9/aarch64/OracleLinux-R8-U9-aarch64-dvd.iso"
iso_checksum            = "c732ec9bb4a85349c0f1ca82020a8514341247506d114b8b79ec32bf99d59ea0"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "arm-other-64"
boot_command            = ["<wait><up>e<wait><down><down><end><wait> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/8ks.cfg <leftCtrlOn>x<leftCtrlOff>"]
