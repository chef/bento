os_name                 = "alpine"
os_version              = "3.21"
os_arch                 = "x86_64"
iso_url                 = "https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/x86_64/alpine-standard-3.21.3-x86_64.iso"
iso_checksum            = "file:https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/x86_64/alpine-standard-3.21.3-x86_64.iso.sha256"
parallels_guest_os_type = "otherlinux"
vbox_guest_os_type      = "ArchLinux_64"
vmware_guest_os_type    = "otherlinux-64"
boot_command            = [
  "<enter><wait2><enter><wait2>",
  "root<enter><wait2>",
  "setup-interfaces -a -r<enter><wait5>",
  "wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/alpine/install.sh -O install.sh<enter><wait2>",
  "sh install.sh {{ .HTTPIP }} {{ .HTTPPort }}<enter>"
]
