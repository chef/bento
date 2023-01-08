os_name                 = "ubuntu"
os_version              = "18.04"
os_arch                 = "x86_64"
iso_url                 = "http://cdimage.ubuntu.com/ubuntu/releases/18.04.6/release/ubuntu-18.04.6-server-amd64.iso"
iso_checksum            = "f5cbb8104348f0097a8e513b10173a07dbc6684595e331cb06f93f385d0aecf6"
hyperv_generation       = 2
parallels_guest_os_type = "ubuntu"
vbox_guest_os_type      = "Ubuntu_64"
vmware_guest_os_type    = "ubuntu-64"
boot_command            = ["<wait5><esc>", "<wait5><esc>", "<wait5><enter><wait5>", "/install/vmlinuz auto console-setup/ask_detect=false", " console-setup/layoutcode=us", " console-setup/modelcode=pc105", " debconf/frontend=noninteractive", " debian-installer=en_US.UTF-8", " fb=false", " initrd=/install/initrd.gz", " kbd-chooser/method=us", " keyboard-configuration/layout=USA", " keyboard-configuration/variant=USA", " locale=en_US.UTF-8", " netcfg/get_hostname=vagrant", " grub-installer/bootdev=/dev/sda", " noapic", " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ubuntu/preseed.cfg", " ---", "<enter><wait>"]
boot_command_hyperv     = ["<esc><wait10><esc><esc><enter><wait>set gfxpayload=1024x768<enter>linux /install/vmlinuz preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ubuntu/preseed-hyperv.cfg debian-installer=en_US.UTF-8 auto locale=en_US.UTF-8 kbd-chooser/method=us hostname={{ .Name }} fb=false debconf/frontend=noninteractive keyboard-configuration/modelcode=SKIP keyboard-configuration/layout=USA keyboard-configuration/variant=USA console-setup/ask_detect=false <enter>initrd /install/initrd.gz<enter>boot<enter>"]
