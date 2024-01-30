os_name                 = "oracle"
os_version              = "8.9"
os_arch                 = "x86_64"
iso_url                 = "https://yum.oracle.com/ISOS/OracleLinux/OL8/u9/x86_64/OracleLinux-R8-U9-x86_64-dvd.iso"
iso_checksum            = "ce90b598be2e9889fa880128fc53b3e9c1f95d9e31859759e5e180602312c181"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<wait><up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/8ks.cfg<enter><wait>"]
