os_name                 = "ubuntu"
os_version              = "18.04"
os_arch                 = "aarch64"
iso_url                 = "https://cdimage.ubuntu.com/releases/18.04.6/release/ubuntu-18.04.6-server-arm64.iso"
iso_checksum            = "0a20ef21181a36588f8fb670cc63e8d326fa6e715b526543d300a68de389055f"
hyperv_generation       = 2
parallels_guest_os_type = "ubuntu"
vbox_guest_os_type      = "Ubuntu_64"
vmware_guest_os_type    = "arm-ubuntu-64"
boot_command            = ["<wait>e<wait><down><down><down><end><wait>", "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>", "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>", "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>", "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>", "<bs><wait>auto console-setup/ask_detect=false", " console-setup/layoutcode=us", " console-setup/modelcode=pc105", " debconf/frontend=noninteractive", " debian-installer=en_US.UTF-8", " fb=false", " initrd=/install/initrd.gz", " kbd-chooser/method=us", " keyboard-configuration/layout=USA", " keyboard-configuration/variant=USA", " locale=en_US.UTF-8", " netcfg/get_hostname=vagrant", " grub-installer/bootdev=/dev/sda", " noapic", " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ubuntu/preseed.cfg", " ---", "<f10><wait>"]
