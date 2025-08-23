os_name                 = "oraclelinux"
os_version              = "10.0"
os_arch                 = "aarch64"
iso_url                 = "https://yum.oracle.com/ISOS/OracleLinux/OL10/u0/aarch64/OracleLinux-R10-U0-aarch64-boot-uek.iso"
iso_checksum            = "file:https://linux.oracle.com/security/gpg/checksum/OracleLinux-R10-U0-Server-aarch64.checksum"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "Oracle_arm64"
vmware_guest_os_type    = "arm-rhel9-64"
boot_command            = ["<wait><up>e<wait><down><down><end><wait> inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/ks.cfg inst.repo=https://yum.oracle.com/repo/OracleLinux/OL10/baseos/latest/aarch64/ <leftCtrlOn>x<leftCtrlOff>"]
