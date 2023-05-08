os_name                 = "debian"
os_version              = "11.7"
os_arch                 = "x86_64"
iso_url                 = "https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-11.7.0-amd64-DVD-1.iso"
iso_checksum            = "cfbb1387d92c83f49420eca06e2d11a23e5a817a21a5d614339749634709a32f"
parallels_guest_os_type = "debian"
vbox_guest_os_type      = "Debian_64"
vmware_guest_os_type    = "debian-64"
boot_command            = ["<wait><esc><wait>auto preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian/preseed.cfg netcfg/get_hostname={{ .Name }}<enter>"]
