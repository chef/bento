os_name                 = "oracle"
os_version              = "9.3"
os_arch                 = "x86_64"
iso_url                 = "https://yum.oracle.com/ISOS/OracleLinux/OL9/u3/x86_64/OracleLinux-R9-U3-x86_64-dvd.iso"
iso_checksum            = "242f0ecc37417995137507862cb170215c0b5bd512c47badd16b623686ef39e2"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<wait><up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/9ks.cfg<enter><wait>"]
