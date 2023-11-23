os_name                 = "centos"
os_version              = "7.9"
os_arch                 = "aarch64"
iso_url                 = "https://quantum-mirror.hu/mirrors/pub/centos-altarch/7.9.2009/isos/aarch64/CentOS-7-aarch64-Minimal-2009.iso"
iso_checksum            = "1bef71329e51f9bed12349aa026b3fe0c4bb27db729399a3f9addae22848da9b"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "arm-centos-64"
boot_command            = ["<wait><up>e<wait><down><down><end><wait> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/7ks.cfg <leftCtrlOn>x<leftCtrlOff>"]
