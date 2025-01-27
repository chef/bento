os_name                 = "oraclelinux"
os_version              = "9.5"
os_arch                 = "x86_64"
iso_url                 = "https://yum.oracle.com/ISOS/OracleLinux/OL9/u5/x86_64/OracleLinux-R9-U5-x86_64-dvd.iso"
iso_checksum            = "file:https://linux.oracle.com/security/gpg/checksum/OracleLinux-R9-U5-Server-x86_64.checksum"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<wait><up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/9ks.cfg<enter><wait>"]
