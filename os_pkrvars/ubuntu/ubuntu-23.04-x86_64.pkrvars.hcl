os_name                 = "ubuntu"
os_version              = "23.04"
os_arch                 = "x86_64"
iso_url                 = "https://releases.ubuntu.com/23.04/ubuntu-23.04-live-server-amd64.iso"
iso_checksum            = "file:https://releases.ubuntu.com/23.04/SHA256SUMS"
hyperv_generation       = 2
parallels_guest_os_type = "ubuntu"
vbox_guest_os_type      = "Ubuntu_64"
vmware_guest_os_type    = "ubuntu-64"
boot_command            = ["<wait>e<wait><down><down><down><end> autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu/<wait><f10><wait>"]
