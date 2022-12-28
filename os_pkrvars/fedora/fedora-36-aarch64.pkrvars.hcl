os_name                 = "fedora"
os_version              = "36"
os_arch                 = "x86_64"
iso_url                 = "http://download.fedoraproject.org/pub/fedora/linux/releases/36/Server/aarch64/iso/Fedora-Server-dvd-aarch64-36-1.5.iso"
iso_checksum            = "sha256:0ab4000575ff8b258576750ecf4ca39b266f0c88cab5fe3d8d2f88c9bea4830d"
parallels_guest_os_type = "fedora-core"
vbox_guest_os_type      = "Fedora_64"
vmware_guest_os_type    = "fedora-64"
boot_command            = ["<up><wait>e<down><down><end> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/fedora/ks.cfg<enter><wait><f10>"]
