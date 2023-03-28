os_name                 = "fedora"
os_version              = "37"
os_arch                 = "aarch64"
iso_url                 = "https://download.fedoraproject.org/pub/fedora/linux/releases/37/Server/aarch64/iso/Fedora-Server-dvd-aarch64-37-1.7.iso"
iso_checksum            = "sha256:1c2deba876bd2da3a429b1b0cd5e294508b8379b299913d97dd6dd6ebcd8b56f"
parallels_guest_os_type = "fedora-core"
vbox_guest_os_type      = "Fedora_64"
vmware_guest_os_type    = "arm-fedora-64"
boot_command            = ["<wait><up><up>e<wait><down><down><end> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/fedora/ks.cfg<F10><wait>"]
