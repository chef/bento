os_name                 = "fedora"
os_version              = "36"
os_arch                 = "x86_64"
iso_url                 = "https://ftp-nyc.osuosl.org/pub/fedora/linux/releases/36/Server/x86_64/iso/Fedora-Server-dvd-x86_64-36-1.5.iso"
iso_checksum            = "sha256:5edaf708a52687b09f9810c2b6d2a3432edac1b18f4d8c908c0da6bde0379148"
parallels_guest_os_type = "fedora-core"
vbox_guest_os_type      = "Fedora_64"
vmware_guest_os_type    = "fedora-64"
boot_command            = ["<up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/fedora/ks.cfg<enter><wait>"]
