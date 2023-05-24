os_name                 = "ubuntu"
os_version              = "20.04"
os_arch                 = "x86_64"
iso_url                 = "https://releases.ubuntu.com/focal/ubuntu-20.04.6-live-server-amd64.iso"
iso_checksum            = "file:https://releases.ubuntu.com/focal/SHA256SUMS"
hyperv_generation       = 2
parallels_guest_os_type = "ubuntu"
vbox_guest_os_type      = "Ubuntu_64"
vmware_guest_os_type    = "ubuntu-64"
boot_wait               = "2s"
boot_command            = ["<wait><esc><esc><esc><enter>/casper/vmlinuz initrd=/casper/initrd quiet autoinstall ds=nocloud-net;s=http://{{.HTTPIP}}:{{.HTTPPort}}/ubuntu/<enter>"]
