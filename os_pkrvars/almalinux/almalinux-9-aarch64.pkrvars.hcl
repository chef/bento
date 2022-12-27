os_name                 = "almalinux"
os_version              = "9.1"
os_arch                 = "aarch64"
is_windows              = false
iso_url                 = "https://repo.almalinux.org/almalinux/9.1/isos/aarch64/AlmaLinux-9.1-aarch64-dvd.iso"
iso_checksum            = "a6f0fb355b9c82f13a95f3f02e19b0f07906a7e0f27e3bca144338ebac9abf40"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["e<wait><down><down><end><wait> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/9ks.cfg <leftCtrlOn>x<leftCtrlOff>"]
boot_command_hyperv = ["<wait5><up><wait5><tab> text ks=hd:fd0:/ks.cfg<enter><wait5><esc>"]
