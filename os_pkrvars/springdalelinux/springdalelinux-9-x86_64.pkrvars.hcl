os_name                 = "springdalelinux"
os_version              = "9.2"
os_arch                 = "x86_64"
iso_url                 = "http://springdale.princeton.edu/data/springdale/9/x86_64/iso/Springdale%20Linux-9.2-x86_64-netinst.iso"
iso_checksum            = "88138260fec7898decf421fe0ae53953f9512c68009dd24cbd897ce226c6295d"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<wait><up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/springdalelinux/9ks.cfg<enter><wait>"]
