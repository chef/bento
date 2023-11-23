os_name                 = "ubuntu"
os_version              = "20.04"
os_arch                 = "aarch64"
iso_url                 = "http://cdimage.ubuntu.com/releases/focal/release/ubuntu-20.04.5-live-server-arm64.iso"
iso_checksum            = "sha256:e42d6373dd39173094af5c26cbf2497770426f42049f8b9ea3e60ce35bebdedf"
parallels_guest_os_type = "ubuntu"
vbox_guest_os_type      = "Ubuntu_64"
vmware_guest_os_type    = "arm-ubuntu-64"
boot_command            = ["<wait><esc>linux /casper/vmlinuz quiet autoinstall ds='nocloud-net;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu/'<enter>initrd /casper/initrd<enter>boot<enter>"]
