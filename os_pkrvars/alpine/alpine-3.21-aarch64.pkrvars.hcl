os_name                 = "alpine"
os_version              = "3.21"
os_arch                 = "aarch64"
iso_url                 = "https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/aarch64/alpine-standard-3.21.3-aarch64.iso"
iso_checksum            = "file:https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/aarch64/alpine-standard-3.21.3-aarch64.iso.sha256"
parallels_guest_os_type = "otherlinux"
vbox_guest_os_type      = "ArchLinux_arm64"
vmware_guest_os_type    = "otherlinux"
parallels_boot_wait     = "0s"
boot_command            = [
  "<enter><wait2><enter><wait2>",
  "root<enter><wait2>",
  "echo 'HELLO WORLD' > /dev/ttyAMA0<enter><wait2>",
  "setup-interfaces -a -r > /dev/ttyAMA0 2>&1<enter><wait5>",
  "ifconfig > /dev/ttyAMA0 2>&1<enter><wait2>",
  "ping -c 1 {{ .HTTPIP }} > /dev/ttyAMA0 2>&1<enter><wait2>",
  "wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/alpine/install.sh -O install.sh > /dev/ttyAMA0 2>&1<enter><wait2>",
  "cat install.sh > /dev/ttyAMA0 2>&1<enter><wait2>",
  "sh install.sh {{ .HTTPIP }} {{ .HTTPPort }} > /dev/ttyAMA0 2>&1<enter>"
]
