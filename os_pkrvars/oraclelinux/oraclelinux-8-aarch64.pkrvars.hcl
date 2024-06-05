os_name                 = "oraclelinux"
os_version              = "8.10"
os_arch                 = "aarch64"
iso_url                 = "https://yum.oracle.com/ISOS/OracleLinux/OL8/u10/aarch64/OracleLinux-R8-U10-aarch64-dvd.iso"
iso_checksum            = "file:https://linux.oracle.com/security/gpg/checksum/OracleLinux-R8-U10-Server-aarch64.checksum"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "arm-other-64"
boot_command            = ["<wait><up>e<wait><down><down><end><wait> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/8ks.cfg <leftCtrlOn>x<leftCtrlOff>"]
