os_name                 = "scientificlinux"
os_version              = "7.9"
os_arch                 = "x86_64"
is_windows              = false
iso_url                 = "http://www.gtlib.gatech.edu/pub/scientific/7.9/x86_64/iso/SL-7-DVD-x86_64.iso"
iso_checksum            = "7ac643e164c4a0da0b9f33411c68368cf908e0c34254904044957a3ca7793934"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/7ks.cfg<enter><wait>"]
boot_command_hyperv     = ["<wait5><up><wait5><tab> text ks=hd:fd0:/ks.cfg<enter><wait5><esc>"]
