os_name                 = "ubuntu"
os_version              = "20.04"
os_arch                 = "x86_64"
iso_url                 = "https://releases.ubuntu.com/focal/ubuntu-20.04.5-live-server-amd64.iso"
iso_checksum            = "sha256:5035be37a7e9abbdc09f0d257f3e33416c1a0fb322ba860d42d74aa75c3468d4"
hyperv_generation       = 2
parallels_guest_os_type = "ubuntu"
vbox_guest_os_type      = "Ubuntu_64"
vmware_guest_os_type    = "ubuntu-64"
boot_command            = ["<wait>", "<esc><wait>", "<esc><wait>", "<f6><wait>", "<esc><wait>", "<bs><bs><bs><bs>", " autoinstall", " ds=nocloud-net;s=http://<wait5>{{.HTTPIP}}<wait5>:{{.HTTPPort}}/ubuntu/", " ---", "<enter>"]
boot_command_hyperv     = ["<wait>", "<esc><wait>", "<esc><wait>", "<f6><wait>", "<esc><wait>", "<bs><bs><bs><bs>", " autoinstall", " ds=nocloud-net;s=http://<wait5>{{.HTTPIP}}<wait5>:{{.HTTPPort}}/ubuntu/", " ---", "<enter>"]
