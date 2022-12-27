os_name                 = "ubuntu"
os_version              = "22.10"
os_arch                 = "x86_64"
is_windows              = false
iso_url                 = "http://releases.ubuntu.com/kinetic/ubuntu-22.10-live-server-amd64.iso"
iso_checksum            = "874452797430a94ca240c95d8503035aa145bd03ef7d84f9b23b78f3c5099aed"
hyperv_generation       = 2
parallels_guest_os_type = "ubuntu"
vbox_guest_os_type      = "Ubuntu_64"
vmware_guest_os_type    = "ubuntu-64"
boot_command            = ["<wait5><esc><wait><f6><wait><esc><wait> <bs><bs><bs><bs><wait> autoinstall<wait5> ds=nocloud-net<wait5>;s=http://<wait5>{{ .HTTPIP }}<wait5>:{{ .HTTPPort }}/ubuntu/<wait5> ---<wait5><enter><wait5>"]
boot_command_hyperv     = ["<wait5><esc><wait><f6><wait><esc><wait> <bs><bs><bs><bs><wait> autoinstall<wait5> ds=nocloud-net<wait5>;s=http://<wait5>{{ .HTTPIP }}<wait5>:{{ .HTTPPort }}/ubuntu/<wait5> ---<wait5><enter><wait5>"]
