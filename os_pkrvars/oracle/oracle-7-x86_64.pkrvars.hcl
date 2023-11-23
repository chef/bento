os_name                 = "oracle"
os_version              = "7.9"
os_arch                 = "x86_64"
iso_url                 = "http://mirrors.dotsrc.org/oracle-linux/OL7/u9/x86_64/OracleLinux-R7-U9-Server-x86_64-dvd.iso"
iso_checksum            = "dc2782bfd92b4c060cf8006fbc6e18036c27f599eebf3584a1a2ac54f008bf2f"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<wait><up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/7ks.cfg<enter><wait>"]
