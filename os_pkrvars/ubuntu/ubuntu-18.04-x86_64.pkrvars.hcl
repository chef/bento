os_name                 = "ubuntu"
os_version              = "18.04"
os_arch                 = "x86_64"
iso_url                 = "https://releases.ubuntu.com/18.04.6/ubuntu-18.04.6-live-server-amd64.iso"
iso_checksum            = "6c647b1ab4318e8c560d5748f908e108be654bad1e165f7cf4f3c1fc43995934"
hyperv_generation       = 2
parallels_guest_os_type = "ubuntu"
vbox_guest_os_type      = "Ubuntu_64"
vmware_guest_os_type    = "ubuntu-64"
boot_command = [
  "<wait>",
  "<esc><wait>",
  "<esc><wait>",
  "<f6><wait>",
  "<esc><wait>",
  "<bs><bs><bs><bs>",
  " auto",
  " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ubuntu/preseed.cfg",
  " ---",
  "<enter>"
]
#boot_command = [
#  "<wait><esc><wait><esc><wait><esc><wait><enter><wait>",
#  "linux /casper/vmlinuz boot=casper hostname={{ .Name }} textonly preseed/allow-network=true --- initrd /casper/initrd preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ubuntu/preseed.cfg"
#  "autoinstall hostname={{ .Name }} textonly preseed/allow-network=true preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ubuntu/preseed.cfg",
#  "<enter><wait>"
#]
#boot_command = [
#  "<waite><esc><wait>",
#  "<esc><wait>",
#  "<esc><wait>",
#  "<enter><wait>",
#  " auto",
#  " netcfg/get_hostname={{ .Name }}",
#  " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ubuntu/preseed.cfg",
#  "<enter><wait>"
#]
#boot_command = [
#  "<waite2><esc><wait2>",
#  "<esc><wait2>",
#  "<esc><wait2>",
#  "<enter><wait2>",
#  "/install/vmlinuz<wait>",
#  " auto<wait>",
#  " console-setup/ask_detect=false<wait>",
#  " console-setup/layoutcode=us<wait>",
#  " console-setup/modelcode=pc105<wait>",
#  " debconf/frontend=noninteractive<wait>",
#  " debian-installer=en_US.UTF-8<wait>",
#  " fb=false<wait>",
#  " initrd=/install/initrd.gz<wait>",
#  " kbd-chooser/method=us<wait>",
#  " keyboard-configuration/layout=USA<wait>",
#  " keyboard-configuration/variant=USA<wait>",
#  " locale=en_US.UTF-8<wait>",
#  " netcfg/get_domain=vm<wait>",
#  " netcfg/get_hostname=vagrant<wait>",
#  " grub-installer/bootdev=/dev/sda<wait>",
#  " noapic<wait>",
#  " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ubuntu/preseed.cfg<wait>",
#  " -- <wait>",
#  "<enter><wait>"
#]
boot_command_hyperv     = ["<esc><wait10><esc><esc><enter><wait>set gfxpayload=1024x768<enter>linux /install/vmlinuz preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ubuntu/preseed-hyperv.cfg debian-installer=en_US.UTF-8 auto locale=en_US.UTF-8 kbd-chooser/method=us hostname={{ .Name }} fb=false debconf/frontend=noninteractive keyboard-configuration/modelcode=SKIP keyboard-configuration/layout=USA keyboard-configuration/variant=USA console-setup/ask_detect=false <enter>initrd /install/initrd.gz<enter>boot<enter>"]
