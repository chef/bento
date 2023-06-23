os_name                 = "opensuse"
os_version              = "15.4"
os_arch                 = "aarch64"
iso_url                 = "http://provo-mirror.opensuse.org/distribution/leap/15.4/iso/openSUSE-Leap-15.4-DVD-aarch64-Media.iso"
iso_checksum            = "d87f79b2b723f9baaeedd9e2be0365c04081e51a4f7f7f08c7ab3eee0c3e0fae"
parallels_guest_os_type = "opensuse"
vbox_guest_os_type      = "OpenSUSE_64"
vmware_guest_os_type    = "arm-other5xlinux-64"
boot_command            = ["<wait5><esc><wait>e<wait><down><down><down><down><end> biosdevname=0 net.ifnames=0 netdevice=eth0 netsetup=dhcp lang=en_US textmode=1 modprobe.blacklist=vmwgfx autoyast=http://{{ .HTTPIP }}:{{ .HTTPPort }}/opensuse/autoinst-uefi.xml<f10><wait>"]
