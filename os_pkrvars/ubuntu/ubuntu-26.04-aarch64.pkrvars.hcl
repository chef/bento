os_name                 = "ubuntu"
os_version              = "26.04"
os_arch                 = "aarch64"
iso_url                 = "https://cdimage.ubuntu.com/releases/26.04/snapshot1/ubuntu-26.04-live-server-arm64.iso
iso_checksum            = "file:https://cdimage.ubuntu.com/releases/26.04/snapshot1/SHA256SUMS
parallels_guest_os_type = "ubuntu"
vbox_guest_os_type      = "Ubuntu26_LTS_arm64"
vmware_guest_os_type    = "arm-ubuntu-64"
utm_vm_icon             = "ubuntu"
boot_command            = ["<wait>e<wait><down><down><down><end> autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu/<wait><f10><wait>"]
