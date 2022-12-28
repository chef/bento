os_name                 = "centos"
os_version              = "7.9"
os_arch                 = "aarch64"
is_windows              = false
iso_url                 = "https://mirror.facebook.net/centos-altarch/7.9.2009/isos/aarch64/CentOS-7-aarch64-Minimal-2009.iso"
iso_checksum            = "1bef71329e51f9bed12349aa026b3fe0c4bb27db729399a3f9addae22848da9b"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["e<wait><down><down><end><wait> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/7ks.cfg <leftCtrlOn>x<leftCtrlOff>"]
boot_command_hyperv     = ["<wait5><up><wait5><tab> text ks=hd:fd0:/ks.cfg<enter><wait5><esc>"]
