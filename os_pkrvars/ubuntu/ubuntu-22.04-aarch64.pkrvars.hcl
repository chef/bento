os_name                 = "ubuntu"
os_version              = "22.04"
os_arch                 = "aarch64"
iso_url                 = "https://cdimage.ubuntu.com/releases/22.04/release/ubuntu-22.04.3-live-server-arm64.iso"
iso_checksum            = "file:https://cdimage.ubuntu.com/releases/22.04/release/SHA256SUMS"
hyperv_generation       = 2
parallels_guest_os_type = "ubuntu"
vbox_guest_os_type      = "Ubuntu_64"
vmware_guest_os_type    = "arm-ubuntu-64"
boot_command            = ["<wait>e<wait><down><down><down><end><wait> autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu/<f10><wait>"]
