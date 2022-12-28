os_name                 = "centos"
os_version              = "7.9"
os_arch                 = "aarch64"
iso_url                 = "https://quantum-mirror.hu/mirrors/pub/centos-altarch/7.9.2009/isos/aarch64/CentOS-7-aarch64-Everything-2009.iso"
iso_checksum            = "b898822822fd5ffacc8da074adcd6b882ac0f73a269111b15871e16c2ce9d774"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<up>e<wait><down><down><end><wait> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/7ks.cfg <leftCtrlOn>x<leftCtrlOff>"]
boot_command_hyperv     = ["<wait5><up><wait5><tab> text ks=hd:fd0:/ks.cfg<enter><wait5><esc>"]
