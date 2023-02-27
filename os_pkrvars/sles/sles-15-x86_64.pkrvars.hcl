os_name                 = "suse"
os_version              = "15.4"
os_arch                 = "x86_64"
iso_url                 = "https://updates.suse.com/SUSE/Products/SLE-Product-SLES/15-SP4/x86_64/iso/SLE-15-SP4-Online-x86_64-GM-Media1.iso"
iso_checksum            = "c0ceebe14d23c6c9484a1594fc5159225292f0847f7f15046f45a83319536d0e"
parallels_guest_os_type = "suse"
vbox_guest_os_type      = "SUSE_LE_64"
vmware_guest_os_type    = "sles15-64"
boot_command            = ["<wait><esc><enter><wait>linux netdevice=eth0 netsetup=dhcp install=cd:/<wait> lang=en_US autoyast=http://{{ .HTTPIP }}:{{ .HTTPPort }}/sles/15-autoinst.xml<wait> textmode=1<wait><enter><wait>"]
