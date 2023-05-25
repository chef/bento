os_name                 = "oracle"
os_version              = "9.2"
os_arch                 = "x86_64"
iso_url                 = "https://yum.oracle.com/ISOS/OracleLinux/OL9/u2/x86_64/OracleLinux-R9-U2-x86_64-dvd.iso"
iso_checksum            = "cac3c41cc2d3467ba8902a5d74575bcf460f129634d5a0d1d67d87094dd70b09"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<wait><up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/9ks.cfg<enter><wait>"]
