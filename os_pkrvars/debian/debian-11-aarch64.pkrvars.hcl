os_name                 = "debian"
os_version              = "11.7"
os_arch                 = "aarch64"
iso_url                 = "https://cdimage.debian.org/cdimage/archive/latest-oldstable/arm64/iso-dvd/debian-11.7.0-arm64-DVD-1.iso"
iso_checksum            = "file:https://cdimage.debian.org/cdimage/archive/latest-oldstable/arm64/iso-dvd/SHA256SUMS"
parallels_guest_os_type = "debian"
vbox_guest_os_type      = "Debian_64"
vmware_guest_os_type    = "arm-debian-64"
boot_command            = ["<wait><up>e<wait><down><down><down><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><wait>install <wait> preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian/preseed.cfg <wait>debian-installer=en_US.UTF-8 <wait>auto <wait>locale=en_US.UTF-8 <wait>kbd-chooser/method=us <wait>keyboard-configuration/xkb-keymap=us <wait>netcfg/get_hostname={{ .Name }} <wait>netcfg/get_domain=vagrantup.com <wait>fb=false <wait>debconf/frontend=noninteractive <wait>console-setup/ask_detect=false <wait>console-keymaps-at/keymap=us <wait>grub-installer/bootdev=/dev/sda <wait><f10><wait>"]
