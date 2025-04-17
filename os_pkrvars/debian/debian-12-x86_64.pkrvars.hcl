os_name                 = "debian"
os_version              = "12.10"
os_arch                 = "x86_64"
iso_url                 = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.10.0-amd64-netinst.iso"
iso_checksum            = "file:https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS"
parallels_guest_os_type = "debian"
vbox_guest_os_type      = "Debian12_64"
vmware_guest_os_type    = "debian-64"
boot_command            = ["<wait><esc><wait>auto preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian/preseed.cfg netcfg/get_hostname={{ .Name }}<enter>"]
