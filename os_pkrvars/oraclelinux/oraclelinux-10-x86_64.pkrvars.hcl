os_name                 = "oraclelinux"
os_version              = "10.0"
os_arch                 = "x86_64"
iso_url                 = "https://yum.oracle.com/ISOS/OracleLinux/OL10/u0/x86_64/OracleLinux-R10-U0-x86_64-boot.iso"
iso_checksum            = "file:https://linux.oracle.com/security/gpg/checksum/OracleLinux-R10-U0-Server-x86_64.checksum"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "Oracle_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<wait><up><wait>e<wait><down><wait><down><wait><end><wait> inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/10ks.cfg inst.repo=https://yum.oracle.com/repo/OracleLinux/OL10/baseos/latest/x86_64/ <leftCtrlOn>x<leftCtrlOff>"]
