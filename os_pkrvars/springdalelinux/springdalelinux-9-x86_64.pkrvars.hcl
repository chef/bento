os_name                 = "springdalelinux"
os_version              = "9.1"
os_arch                 = "x86_64"
iso_url                 = "http://springdale.princeton.edu/data/springdale/9/x86_64/iso/Springdale%20Linux-9.1-x86_64-netinst.iso"
iso_checksum            = "a282a61dfd9ac587aa635688ec3eae8ac95524094dac0355543c3c0f6df84253"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/springdalelinux/9ks.cfg<enter><wait>"]
boot_command_hyperv     = ["<wait5><up><wait5><tab> text ks=hd:fd0:/ks.cfg<enter><wait5><esc>"]
