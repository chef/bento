os_name                 = "ubuntu"
os_version              = "22.04"
os_arch                 = "x86_64"
is_windows              = false
iso_url                 = "http://releases.ubuntu.com/jammy/ubuntu-22.04.1-live-server-amd64.iso"
iso_checksum            = "sha256:10f19c5b2b8d6db711582e0e27f5116296c34fe4b313ba45f9b201a5007056cb"
hyperv_generation       = 2
parallels_guest_os_type = "ubuntu"
vbox_guest_os_type      = "Ubuntu_64"
vmware_guest_os_type    = "ubuntu-64"
boot_command            = ["<wait5><esc><wait><f6><wait><esc><wait> <bs><bs><bs><bs><wait> autoinstall<wait5> ds=nocloud-net<wait5>;s=http://<wait5>{{ .HTTPIP }}<wait5>:{{ .HTTPPort }}/<wait5> ---<wait5><enter><wait5>"]
boot_command_hyperv     = ["<wait5><esc><wait><f6><wait><esc><wait> <bs><bs><bs><bs><wait> autoinstall<wait5> ds=nocloud-net<wait5>;s=http://<wait5>{{ .HTTPIP }}<wait5>:{{ .HTTPPort }}/<wait5> ---<wait5><enter><wait5>"]
