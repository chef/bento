os_name                 = "oraclelinux"
os_version              = "9.3"
os_arch                 = "aarch64"
iso_url                 = "https://yum.oracle.com/ISOS/OracleLinux/OL9/u3/aarch64/OracleLinux-R9-U3-aarch64-dvd.iso"
iso_checksum            = "7cc50a48f361cb1100a28621ba455edaac3a38182f6dd3fe67588b3eeaf18dc3"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "arm-rhel9-64"
boot_command            = ["<wait><up>e<wait><down><down><end><wait> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/9ks.cfg <leftCtrlOn>x<leftCtrlOff>"]
