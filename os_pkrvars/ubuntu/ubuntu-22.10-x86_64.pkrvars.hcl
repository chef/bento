os_name                 = "ubuntu"
os_version              = "22.10"
os_arch                 = "x86_64"
iso_url                 = "http://releases.ubuntu.com/kinetic/ubuntu-22.10-live-server-amd64.iso"
iso_checksum            = "874452797430a94ca240c95d8503035aa145bd03ef7d84f9b23b78f3c5099aed"
hyperv_generation       = 2
parallels_guest_os_type = "ubuntu"
vbox_guest_os_type      = "Ubuntu_64"
vmware_guest_os_type    = "ubuntu-64"
boot_command            = ["c<wait>set gfxpayload=keep<enter><wait>linux /casper/vmlinuz quiet autoinstall ds=nocloud-net;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu/ ---<enter><wait>initrd /casper/initrd<wait><enter><wait>boot<enter><wait>"]
boot_command_hyperv     = ["c<wait>set gfxpayload=keep<enter><wait>linux /casper/vmlinuz quiet autoinstall ds=nocloud-net;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu/ ---<enter><wait>initrd /casper/initrd<wait><enter><wait>boot<enter><wait>"]
