os_name                 = "fedora"
os_version              = "38"
os_arch                 = "x86_64"
iso_url                 = "https://download.fedoraproject.org/pub/fedora/linux/releases/38/Server/x86_64/iso/Fedora-Server-dvd-x86_64-38-1.6.iso"
iso_checksum            = "sha256:66b52d7cb39386644cd740930b0bef0a5a2f2be569328fef6b1f9b3679fdc54d"
parallels_guest_os_type = "fedora-core"
vbox_guest_os_type      = "Fedora_64"
vmware_guest_os_type    = "fedora-64"
boot_command            = ["<wait><up>e<wait><down><down><end> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/fedora/ks.cfg<F10><wait>"]
