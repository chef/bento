os_name                 = "rockylinux"
os_version              = "8.7"
os_arch                 = "x86_64"
is_windows              = false
iso_url                 = "http://download.rockylinux.org/pub/rocky/8.7/isos/x86_64/Rocky-8.7-x86_64-dvd1.iso"
iso_checksum            = "file:https://download.rockylinux.org/pub/rocky/8.7/isos/x86_64/CHECKSUM"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/8ks.cfg<enter><wait>"]
boot_command_hyperv     = ["<wait5><up><wait5><tab> text ks=hd:fd0:/ks.cfg<enter><wait5><esc>"]
