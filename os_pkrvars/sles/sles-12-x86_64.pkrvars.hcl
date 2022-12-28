os_name                 = "suse"
os_version              = "12.5"
os_arch                 = "x86_64"
iso_url                 = "https://updates.suse.com/SUSE/Products/SLE-SERVER/12-SP5/x86_64/iso/SLE-12-SP5-Server-DVD-x86_64-GM-DVD1.iso"
iso_checksum            = "5a12561f8c2869bca4f820787971f3b92f44dce77442906115cd21c359327b9f"
parallels_guest_os_type = "suse"
vbox_guest_os_type      = "SUSE_LE_64"
vmware_guest_os_type    = "sles12-64"
boot_command            = ["<esc><enter><wait>linux netdevice=eth0 netsetup=dhcp install=cd:/<wait> lang=en_US autoyast=http://{{ .HTTPIP }}:{{ .HTTPPort }}/sles/12-autoinst.xml<wait> textmode=1<wait><enter><wait>"]
