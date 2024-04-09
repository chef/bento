os_name                 = "suse"
os_version              = "15.5"
os_arch                 = "x86_64"
iso_url                 = "https://updates.suse.com/SUSE/Products/SLE-Product-SLES/15-SP5/x86_64/iso/SLE-15-SP5-Online-x86_64-GM-Media1.iso"
iso_checksum            = "b0920189fd7f2624983a9cf8bc062bbb7a8557658e3feadde77b80e72f66b6ef"
parallels_guest_os_type = "suse"
vbox_guest_os_type      = "SUSE_LE_64"
vmware_guest_os_type    = "sles15-64"
boot_command            = ["<wait><esc><enter><wait>linux netdevice=eth0 netsetup=dhcp install=cd:/<wait> lang=en_US autoyast=http://{{ .HTTPIP }}:{{ .HTTPPort }}/sles/15-autoinst.xml<wait> textmode=1<wait><enter><wait>"]
