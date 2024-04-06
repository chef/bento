os_name                 = "suse"
os_version              = "15.5"
os_arch                 = "x86_64"
iso_url                 = "https://updates.suse.com/SUSE/Products/SLE-Product-SLES/15-SP5/x86_64/iso/SLE-15-SP5-Online-x86_64-GM-Media1.iso"
iso_checksum            = "file:https://updates.suse.com/SUSE/Products/SLE-Product-SLES/15-SP5/x86_64/iso/SLE-15-SP5-Online-x86_64-GM-Media1.iso.sha256?cG8LjpvKJk5s99zXx8YCunM_gPlsrV3xErkmRhADJDmfIysWhWsz5AFyxRn5lORigyB92swHFeUWF8DjU2NxT7xcNanGaH48YzQC_7hnwII646RkhKwo_H3BVPQRtNPjg0qrHJnOu_YovN4HzXry651ObISEzLFnydhD1y4HbDfNVW0ozQaX6A0QBozh_wnu3cc"
parallels_guest_os_type = "suse"
vbox_guest_os_type      = "SUSE_LE_64"
vmware_guest_os_type    = "sles15-64"
boot_command            = ["<wait><esc><enter><wait>linux netdevice=eth0 netsetup=dhcp install=cd:/<wait> lang=en_US autoyast=http://{{ .HTTPIP }}:{{ .HTTPPort }}/sles/15-autoinst.xml<wait> textmode=1<wait><enter><wait>"]
