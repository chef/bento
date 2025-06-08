os_name                 = "alpine"
os_version              = "3_21"
os_arch                 = "aarch64"
iso_url                 = "https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/aarch64/alpine-standard-3.21.3-aarch64.iso"
iso_checksum            = "file:https://dl-cdn.alpinelinux.org/alpine/v3.21/releases/aarch64/alpine-standard-3.21.3-aarch64.iso.sha256"
parallels_guest_os_type = "otherlinux"
vbox_guest_os_type      = "ArchLinux_arm64"
vmware_guest_os_type    = "otherlinux"
parallels_boot_wait     = "0s"
boot_command            = ["root<enter><wait>",
  "ifconfig eth0 up && udhcpc -i eth0<enter><wait5>",
  "wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/answers<enter><wait>",
  "setup-alpine -f answers<enter><wait5>",
  "{{user `ssh_password`}}<enter><wait>",
  "{{user `ssh_password`}}<enter><wait5>",
  "<wait>y<enter><wait10>",
  "rc-service sshd stop<enter>",
  "mount /dev/sda3 /mnt<enter>",
  "echo 'PermitRootLogin yes' >> /mnt/etc/ssh/sshd_config<enter>",
  "umount /mnt<enter>",
  "reboot<enter>"]
