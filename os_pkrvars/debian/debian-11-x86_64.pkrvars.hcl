os_name                 = "debian"
os_version              = "11.7"
os_arch                 = "x86_64"
iso_url                 = "https://cdimage.debian.org/cdimage/archive/latest-oldstable/amd64/iso-dvd/debian-11.7.0-amd64-DVD-1.iso"
iso_checksum            = "file:https://cdimage.debian.org/cdimage/archive/latest-oldstable/amd64/iso-dvd/SHA256SUMS"
parallels_guest_os_type = "debian"
vbox_guest_os_type      = "Debian_64"
vmware_guest_os_type    = "debian-64"
boot_command            = ["<wait><esc><wait>auto preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian/preseed.cfg netcfg/get_hostname={{ .Name }}<enter>"]
