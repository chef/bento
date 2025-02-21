os_name                 = "opensuse-leap"
os_version              = "15.6"
os_arch                 = "x86_64"
iso_url                 = "https://download.opensuse.org/distribution/leap/15.6/iso/openSUSE-Leap-15.6-NET-x86_64-Media.iso"
iso_checksum            = "file:https://download.opensuse.org/distribution/leap/15.6/iso/openSUSE-Leap-15.6-NET-x86_64-Media.iso.sha256"
parallels_guest_os_type = "opensuse"
vbox_guest_os_type      = "OpenSUSE_Leap_64"
vmware_guest_os_type    = "opensuse-64"
boot_command            = ["<wait5><esc><enter><wait>linux biosdevname=0 net.ifnames=0 netdevice=eth0 netsetup=dhcp lang=en_US textmode=1 autoyast=http://{{ .HTTPIP }}:{{ .HTTPPort }}/opensuse/autoinst.xml<enter><wait>"]
