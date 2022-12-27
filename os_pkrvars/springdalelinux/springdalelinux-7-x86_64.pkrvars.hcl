os_name                 = "springdalelinux"
os_version              = "7.9"
os_arch                 = "x86_64"
is_windows              = false
iso_url                 = "http://springdale.princeton.edu/data/springdale/7.5/x86_64/iso/Springdale%20Linux-7.5-x86_64-DVD.iso"
iso_checksum            = "f4324776f92ee6f4d8a8fc96ddcb7b346e96a51cbc6eac39b51ac8b485a602ad"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/7ks.cfg<enter><wait>"]
boot_command_hyperv     = ["<wait5><up><wait5><tab> text ks=hd:fd0:/ks.cfg<enter><wait5><esc>"]
