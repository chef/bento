os_name                 = "opensuse-leap"
os_version              = "15.6"
os_arch                 = "aarch64"
iso_url                 = "https://download.opensuse.org/distribution/leap/15.6/iso/openSUSE-Leap-15.6-NET-aarch64-Media.iso"
iso_checksum            = "file:https://download.opensuse.org/distribution/leap/15.6/iso/openSUSE-Leap-15.6-NET-aarch64-Media.iso.sha256"
parallels_guest_os_type = "opensuse"
vbox_guest_os_type      = "OpenSUSE_Leap_arm64"
vmware_guest_os_type    = "arm-other-64"
boot_command            = ["<wait5><esc><wait>e<wait><down><down><down><down><end> biosdevname=0 net.ifnames=0 netdevice=eth0 netsetup=dhcp lang=en_US textmode=1 modprobe.blacklist=vmwgfx autoyast=http://{{ .HTTPIP }}:{{ .HTTPPort }}/opensuse/autoinst-uefi.xml<f10><wait>"]
