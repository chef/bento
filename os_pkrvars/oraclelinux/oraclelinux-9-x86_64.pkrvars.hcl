os_name                 = "oraclelinux"
os_version              = "9.6"
os_arch                 = "x86_64"
iso_url                 = "https://yum.oracle.com/ISOS/OracleLinux/OL9/u6/x86_64/OracleLinux-R9-U6-x86_64-boot.iso"
iso_checksum            = "file:https://linux.oracle.com/security/gpg/checksum/OracleLinux-R9-U6-Server-x86_64.checksum"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "Oracle_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<wait><up><wait><tab> inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/9ks.cfg inst.repo=https://yum.oracle.com/repo/OracleLinux/OL9/baseos/latest/x86_64/ <enter><wait>"]
