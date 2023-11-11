os_name                 = "fedora"
os_version              = "39"
os_arch                 = "x86_64"
iso_url                 = "https://mirrors.rit.edu/fedora/fedora/linux/releases/39/Server/x86_64/iso/Fedora-Server-dvd-x86_64-39-1.5.iso"
iso_checksum            = "sha256:2755cdff6ac6365c75be60334bf1935ade838fc18de53d4c640a13d3e904f6e9"
parallels_guest_os_type = "fedora-core"
vbox_guest_os_type      = "Fedora_64"
vmware_guest_os_type    = "fedora-64"
boot_command            = ["<wait><up>e<wait><down><down><end> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/fedora/ks.cfg<F10><wait>"]
