os_name                 = "debian"
os_version              = "10.13"
os_arch                 = "x86_64"
iso_url                 = "https://cdimage.debian.org/cdimage/archive/10.13.0/amd64/iso-dvd/debian-10.13.0-amd64-DVD-1.iso"
iso_checksum            = "07d493c305aa5313e767181af5ef2c2b2758a4a3f57e78fb4a4fcba1dcefb198"
parallels_guest_os_type = "debian"
vbox_guest_os_type      = "Debian_64"
vmware_guest_os_type    = "debian-64"
boot_command            = ["<esc><wait>auto preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian/preseed.cfg netcfg/get_hostname={{ .Name }}<enter>"]
