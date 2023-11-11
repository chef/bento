
os_name                 = "fedora"
os_version              = "39"
os_arch                 = "aarch64"
iso_url                 = "https://mirrors.rit.edu/fedora/fedora/linux/releases/39/Server/aarch64/iso/Fedora-Server-dvd-aarch64-39-1.5.iso"
iso_checksum            = "sha256:d19dc2a39758155fa53e6fd555d0d173ccc8175b55dea48002d499f39cb30ce0"
parallels_guest_os_type = "fedora-core"
vbox_guest_os_type      = "Fedora_64"
vmware_guest_os_type    = "arm-fedora-64"
boot_command            = ["<wait><up><up>e<wait><down><down><end> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/fedora/ks.cfg<F10><wait>"]