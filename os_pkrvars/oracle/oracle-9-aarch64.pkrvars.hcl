os_name                 = "oracle"
os_version              = "9.2"
os_arch                 = "aarch64"
iso_url                 = "https://yum.oracle.com/ISOS/OracleLinux/OL9/u2/aarch64/OracleLinux-R9-U2-aarch64-dvd.iso"
iso_checksum            = "412f1a5e90d11313735a2a98a977f82d0d09642e3ab14a03da36d4e2b0b0d275"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "arm-centos-64"
boot_command            = ["<wait><up>e<wait><down><down><end><wait> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/9ks.cfg <leftCtrlOn>x<leftCtrlOff>"]
