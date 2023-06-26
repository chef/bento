os_name                 = "springdalelinux"
os_version              = "8.8"
os_arch                 = "x86_64"
iso_url                 = "http://springdale.princeton.edu/data/springdale/8/x86_64/iso/Springdale%20Linux-8.8-x86_64-netinst.iso"
iso_checksum            = "8bd617eb9fb050387fdf5abd9445722a1ef247523f2aa66d9cd9f952fbc9f6ff"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<wait><up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/springdalelinux/8ks.cfg<enter><wait>"]
