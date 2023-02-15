os_name                 = "centos-stream"
os_version              = "8"
os_arch                 = "x86_64"
iso_url                 = "http://mirrors.kernel.org/centos/8-stream/isos/x86_64/CentOS-Stream-8-x86_64-latest-dvd1.iso"
iso_checksum            = "file:https://mirrors.edge.kernel.org/centos/8-stream/isos/x86_64/CHECKSUM"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<wait><up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/8ks.cfg<enter><wait>"]
