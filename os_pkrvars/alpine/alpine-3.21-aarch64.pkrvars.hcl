os_name                 = "alpine"
os_version              = "3.21"
os_arch                 = "aarch64"
iso_url                 = "https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/aarch64/alpine-standard-3.21.3-aarch64.iso"
iso_checksum            = "file:https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/aarch64/alpine-standard-3.21.3-aarch64.iso.sha256"
parallels_guest_os_type = "otherlinux"
vbox_guest_os_type      = "ArchLinux_arm64"
vmware_guest_os_type    = "otherlinux"
parallels_boot_wait     = "0s"
boot_command            = ["<up>e<wait><down><down><end> inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/fedora/ks.cfg inst.repo=https://download.fedoraproject.org/pub/fedora/linux/releases/41/Server/aarch64/os/ <F10><wait>"]
