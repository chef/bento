os_name                 = "fedora"
os_version              = "42"
os_arch                 = "x86_64"
iso_url                 = "https://download.fedoraproject.org/pub/fedora/linux/releases/42/Server/x86_64/iso/Fedora-Server-netinst-x86_64-42-1.1.iso"
iso_checksum            = "file:https://download.fedoraproject.org/pub/fedora/linux/releases/42/Server/x86_64/iso/Fedora-Server-42-1.1-x86_64-CHECKSUM"
parallels_guest_os_type = "fedora-core"
vbox_guest_os_type      = "Fedora_64"
vmware_guest_os_type    = "fedora-64"
boot_command            = ["<wait><up>e<wait><down><down><end> inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/fedora/ks.cfg inst.repo=https://download.fedoraproject.org/pub/fedora/linux/releases/42/Server/x86_64/os/ <F10><wait>"]
