os_name                 = "opensuse"
os_version              = "15.4"
os_arch                 = "x86_64"
iso_url                 = "http://sfo-korg-mirror.kernel.org/opensuse/distribution/leap/15.4/iso/openSUSE-Leap-15.4-DVD-x86_64-Media.iso"
iso_checksum            = "4683345f242397c7fd7d89a50731a120ffd60a24460e21d2634e783b3c169695"
parallels_guest_os_type = "opensuse"
vbox_guest_os_type      = "OpenSUSE_64"
vmware_guest_os_type    = "opensuse-64"
boot_command            = ["<wait5><esc><enter><wait>linux biosdevname=0 net.ifnames=0 netdevice=eth0 netsetup=dhcp lang=en_US textmode=1 autoyast=http://{{ .HTTPIP }}:{{ .HTTPPort }}/opensuse/autoinst.xml<enter><wait>"]
