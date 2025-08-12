os_name                 = "suse"
os_version              = "15.7"
os_arch                 = "aarch64"
iso_url                 = "https://updates.suse.com/SUSE/Products/SLE-Product-SLES/15-SP7/aarch64/iso/SLE-15-SP7-Online-aarch64-GM-Media1.iso"
iso_checksum            = "56f67a6d10a502901cc2c291231089e375dd7c2b51fc951d5deaa57439c2686e"
parallels_guest_os_type = "opensuse"
vbox_guest_os_type      = "OpenSUSE_Leap_arm64"
vmware_guest_os_type    = "arm-other-64"
boot_command            = ["<wait><esc><enter><wait>linux netdevice=eth0 netsetup=dhcp install=cd:/<wait> lang=en_US autoyast=http://{{ .HTTPIP }}:{{ .HTTPPort }}/sles/15-autoinst.xml<wait> textmode=1<wait><enter><wait>"]
