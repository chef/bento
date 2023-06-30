os_name                 = "opensuse"
os_version              = "15.5"
os_arch                 = "x86_64"
iso_url                 = "http://sfo-korg-mirror.kernel.org/opensuse/distribution/leap/15.5/iso/openSUSE-Leap-15.5-DVD-x86_64-Media.iso"
iso_checksum            = "file:http://sfo-korg-mirror.kernel.org/opensuse/distribution/leap/15.5/iso/openSUSE-Leap-15.5-DVD-x86_64-Media.iso.sha256"
parallels_guest_os_type = "opensuse"
vbox_guest_os_type      = "OpenSUSE_64"
vmware_guest_os_type    = "opensuse-64"
boot_command            = ["<wait5><esc><enter><wait>linux biosdevname=0 net.ifnames=0 netdevice=eth0 netsetup=dhcp lang=en_US textmode=1 autoyast=http://{{ .HTTPIP }}:{{ .HTTPPort }}/opensuse/autoinst.xml<enter><wait>"]
