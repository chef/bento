os_name                 = "fedora"
os_version              = "37"
os_arch                 = "x86_64"
iso_url                 = "https://download.fedoraproject.org/pub/fedora/linux/releases/37/Server/x86_64/iso/Fedora-Server-dvd-x86_64-37-1.7.iso"
iso_checksum            = "sha256:0a4de5157af47b41a07a53726cd62ffabd04d5c1a4afece5ee7c7a84c1213e4f"
parallels_guest_os_type = "fedora-core"
vbox_guest_os_type      = "Fedora_64"
vmware_guest_os_type    = "fedora-64"
boot_command            = ["<wait><up>e<wait><down><down><end> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/fedora/ks.cfg<F10><wait>"]
