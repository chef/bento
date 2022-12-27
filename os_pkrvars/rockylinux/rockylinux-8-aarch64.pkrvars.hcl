os_name                 = "rockylinux"
os_version              = "8.7"
os_arch                 = "aarch64"
is_windows              = false
iso_url                 = "https://download.rockylinux.org/pub/rocky/8/isos/aarch64/Rocky-8.7-aarch64-dvd1.iso"
iso_checksum            = "file:https://download.rockylinux.org/pub/rocky/8/isos/aarch64/CHECKSUM"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["e<wait><down><down><end><wait> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/9ks.cfg <leftCtrlOn>x<leftCtrlOff>"]
boot_command_hyperv     = ["<wait5><up><wait5><tab> text ks=hd:fd0:/ks.cfg<enter><wait5><esc>"]
