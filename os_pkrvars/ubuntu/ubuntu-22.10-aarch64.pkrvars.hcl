os_name                 = "ubuntu"
os_version              = "22.10"
os_arch                 = "aarch64"
iso_url                 = "https://cdimage.ubuntu.com/releases/22.10/release/ubuntu-22.10-live-server-arm64.iso"
iso_checksum            = "a19d956e993a16fc6496c371e36dcc0eb85d2bdf6a8e86028b92ce62e9f585cd"
hyperv_generation       = 2
parallels_guest_os_type = "ubuntu"
vbox_guest_os_type      = "Ubuntu_64"
vmware_guest_os_type    = "ubuntu-64"
boot_command            = ["<wait5><esc><wait><f6><wait><esc><wait> <bs><bs><bs><bs><wait> autoinstall<wait5> ds=nocloud-net<wait5>;s=http://<wait5>{{ .HTTPIP }}<wait5>:{{ .HTTPPort }}/ubuntu/preseed.cfg<wait5> ---<wait5><enter><wait5>"]
boot_command_hyperv     = ["<wait5><esc><wait><f6><wait><esc><wait> <bs><bs><bs><bs><wait> autoinstall<wait5> ds=nocloud-net<wait5>;s=http://<wait5>{{ .HTTPIP }}<wait5>:{{ .HTTPPort }}/ubuntu/preseed-hyperv.cfg<wait5> ---<wait5><enter><wait5>"]
