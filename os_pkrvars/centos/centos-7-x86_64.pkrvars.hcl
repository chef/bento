os_name                 = "centos"
os_version              = "7.9"
os_arch                 = "x86_64"
iso_url                 = "http://mirrors.kernel.org/centos/7.9.2009/isos/x86_64/CentOS-7-x86_64-Minimal-2009.iso"
iso_checksum            = "file:https://mirrors.edge.kernel.org/centos/7.9.2009/isos/x86_64/sha256sum.txt"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<wait><up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/7ks.cfg<enter><wait>"]
