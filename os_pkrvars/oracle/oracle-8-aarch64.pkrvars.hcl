os_name                 = "oracle"
os_version              = "8.8"
os_arch                 = "aarch64"
iso_url                 = "https://yum.oracle.com/ISOS/OracleLinux/OL8/u8/aarch64/OracleLinux-R8-U8-aarch64-dvd.iso"
iso_checksum            = "6fe0c274b08084787f8d82d8cf2ff7893eea91f018c1f2d0c72383588b2fd480"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "arm-centos-64"
boot_command            = ["<wait><up>e<wait><down><down><end><wait> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/8ks.cfg <leftCtrlOn>x<leftCtrlOff>"]
