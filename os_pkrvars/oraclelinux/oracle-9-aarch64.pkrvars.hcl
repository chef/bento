os_name                 = "oracle"
os_version              = "9.1"
os_arch                 = "aarch64"
iso_url                 = "https://yum.oracle.com/ISOS/OracleLinux/OL9/u1/aarch64/OracleLinux-R9-U1-aarch64-dvd.iso"
iso_checksum            = "3dc4578f53ceb1010f8236b3356f2441ec3f9e840fa60522e470d7f3cdb86cb1"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "arm-centos-64"
boot_command            = ["<wait><up>e<wait><down><down><end><wait> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/9ks.cfg <leftCtrlOn>x<leftCtrlOff>"]
