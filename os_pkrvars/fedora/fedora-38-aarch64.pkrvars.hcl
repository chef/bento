os_name                 = "fedora"
os_version              = "38"
os_arch                 = "aarch64"
iso_url                 = "https://download.fedoraproject.org/pub/fedora/linux/releases/38/Server/aarch64/iso/Fedora-Server-dvd-aarch64-38-1.6.iso"
iso_checksum            = "sha256:0b40485d74fc60c0a78f071396aba78fafb2f8f3b1ab4cbc3388bda82f764f9b"
parallels_guest_os_type = "fedora-core"
vbox_guest_os_type      = "Fedora_64"
vmware_guest_os_type    = "arm-fedora-64"
boot_command            = ["<wait><up><up>e<wait><down><down><end> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/fedora/ks.cfg<F10><wait>"]
