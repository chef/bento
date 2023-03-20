os_name                   = "ubuntu"
os_version                = "22.10"
os_arch                   = "aarch64"
iso_url                   = "https://cdimage.ubuntu.com/releases/22.10/release/ubuntu-22.10-live-server-arm64.iso"
iso_checksum              = "a19d956e993a16fc6496c371e36dcc0eb85d2bdf6a8e86028b92ce62e9f585cd"
hyperv_generation         = 2
parallels_guest_os_type   = "ubuntu"
vbox_guest_os_type        = "Ubuntu_64"
vmware_guest_os_type      = "arm-ubuntu-64"
boot_command              = ["<wait>e<wait><down><down><down><end> autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu/<wait><f10><wait>"]
vmware_cdrom_adapter_type = "sata"
vmware_disk_adapter_type  = "sata"