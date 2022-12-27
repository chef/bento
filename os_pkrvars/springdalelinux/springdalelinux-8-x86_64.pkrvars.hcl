os_name                 = "springdalelinux"
os_version              = "8.7"
os_arch                 = "x86_64"
is_windows              = false
iso_url                 = "http://springdale.princeton.edu/data/springdale/8.7/x86_64/iso/Springdale%20Linux-8.7-x86_64-netinst.iso"
iso_checksum            = "7535d3eadf5d60d12a026ccaf5f1235c660cc985bc1e8b7502a99fd0389407f8"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/8ks.cfg<enter><wait>"]
boot_command_hyperv     = ["<wait5><up><wait5><tab> text ks=hd:fd0:/ks.cfg<enter><wait5><esc>"]
