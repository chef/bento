os_name                 = "almalinux"
os_version              = "9.1"
os_arch                 = "x86_64"
iso_url                 = "https://repo.almalinux.org/almalinux/9/isos/x86_64/AlmaLinux-9.1-update-1-x86_64-minimal.iso"
iso_checksum            = "file:https://repo.almalinux.org/almalinux/9/isos/x86_64/CHECKSUM"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/9ks.cfg<enter><wait>"]
boot_command_hyperv     = ["<wait5><up><wait5><tab> text ks=hd:fd0:/ks.cfg<enter><wait5><esc>"]
