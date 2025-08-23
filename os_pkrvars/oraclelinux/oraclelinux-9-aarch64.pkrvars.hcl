os_name                 = "oraclelinux"
os_version              = "9.6"
os_arch                 = "aarch64"
iso_url                 = "https://yum.oracle.com/ISOS/OracleLinux/OL9/u6/aarch64/OracleLinux-R9-U6-aarch64-boot-uek.iso"
iso_checksum            = "file:https://linux.oracle.com/security/gpg/checksum/OracleLinux-R9-U6-Server-aarch64.checksum"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "Oracle9_arm64"
vmware_guest_os_type    = "arm-rhel9-64"
boot_command            = ["<wait><up>e<wait><down><down><end><wait> inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/ks.cfg inst.repo=https://yum.oracle.com/repo/OracleLinux/OL9/baseos/latest/aarch64/ <leftCtrlOn>x<leftCtrlOff>"]
