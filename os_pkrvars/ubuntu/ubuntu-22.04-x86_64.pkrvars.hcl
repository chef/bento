os_name                 = "ubuntu"
os_version              = "22.04"
os_arch                 = "x86_64"
iso_url                 = "http://releases.ubuntu.com/jammy/ubuntu-22.04.1-live-server-amd64.iso"
iso_checksum            = "sha256:10f19c5b2b8d6db711582e0e27f5116296c34fe4b313ba45f9b201a5007056cb"
hyperv_generation       = 2
parallels_guest_os_type = "ubuntu"
vbox_guest_os_type      = "Ubuntu_64"
vmware_guest_os_type    = "ubuntu-64"
boot_command            = ["c<wait>set gfxpayload=keep<enter><wait>linux /casper/vmlinuz quiet autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu/ ---<enter><wait>initrd /casper/initrd<wait><enter><wait>boot<enter><wait>"]
