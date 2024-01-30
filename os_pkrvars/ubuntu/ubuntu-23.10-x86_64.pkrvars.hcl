os_name                 = "ubuntu"
os_version              = "23.10"
os_arch                 = "x86_64"
iso_url                 = "https://releases.ubuntu.com/mantic/ubuntu-23.10-live-server-amd64.iso"
iso_checksum            = "file:https://releases.ubuntu.com/mantic/SHA256SUMS"
parallels_guest_os_type = "ubuntu"
vbox_guest_os_type      = "Ubuntu_64"
vmware_guest_os_type    = "ubuntu-64"
boot_command            = ["<wait>e<wait><down><down><down><end> autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu/<wait><f10><wait>"]
