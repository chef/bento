os_name                 = "oracle"
os_version              = "8.8"
os_arch                 = "x86_64"
iso_url                 = "https://yum.oracle.com/ISOS/OracleLinux/OL8/u8/x86_64/OracleLinux-R8-U8-x86_64-dvd.iso"
iso_checksum            = "cae39116245ff7c3c86d5305d9c11430ce5c4e512987563435ac59c37a082d7e"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<wait><up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/8ks.cfg<enter><wait>"]
