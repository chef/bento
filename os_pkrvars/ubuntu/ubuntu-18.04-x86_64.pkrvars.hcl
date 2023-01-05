os_name                 = "ubuntu"
os_version              = "18.04"
os_arch                 = "x86_64"
iso_url                 = "https://releases.ubuntu.com/18.04.6/ubuntu-18.04.6-live-server-amd64.iso"
iso_checksum            = "6c647b1ab4318e8c560d5748f908e108be654bad1e165f7cf4f3c1fc43995934"
hyperv_generation       = 2
parallels_guest_os_type = "ubuntu"
vbox_guest_os_type      = "Ubuntu_64"
vmware_guest_os_type    = "ubuntu-64"
boot_command            = ["<esc><wait><esc><f6><wait><esc><wait> <bs><bs><bs>autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ubuntu/preseed.cfg ---<wait><enter><wait>"]
boot_command_hyperv     = ["<esc><wait10><esc><esc><enter><wait>set gfxpayload=1024x768<enter>linux /install/vmlinuz preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ubuntu/preseed-hyperv.cfg debian-installer=en_US.UTF-8 auto locale=en_US.UTF-8 kbd-chooser/method=us hostname={{ .Name }} fb=false debconf/frontend=noninteractive keyboard-configuration/modelcode=SKIP keyboard-configuration/layout=USA keyboard-configuration/variant=USA console-setup/ask_detect=false <enter>initrd /install/initrd.gz<enter>boot<enter>"]
