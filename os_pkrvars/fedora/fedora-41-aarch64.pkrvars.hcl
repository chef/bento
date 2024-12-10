os_name                 = "fedora"
os_version              = "41"
os_arch                 = "aarch64"
iso_url                 = "https://mirrors.rit.edu/fedora/fedora/linux/releases/41/Server/aarch64/iso/Fedora-Server-dvd-aarch64-41-1.4.iso"
iso_checksum            = "sha256:99e7801b943e81f78a7b104fe348196b0ac1bc748ce647378f22a2c875c923ec"
parallels_guest_os_type = "fedora-core"
vbox_guest_os_type      = "Fedora_64"
vmware_guest_os_type    = "arm-fedora-64"
boot_command            = ["<wait><up><up>e<wait><down><down><end> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/fedora/ks.cfg<F10><wait>"]
