os_name                 = "opensuse-leap"
os_version              = "16.0"
os_arch                 = "aarch64"
iso_url                 = "https://download.opensuse.org/distribution/leap/16.0/installer/iso/agama-installer.aarch64-Leap_16.0.iso"
iso_checksum            = "file:https://download.opensuse.org/distribution/leap/16.0/installer/iso/agama-installer.aarch64-Leap_16.0.iso.sha256"
# iso_url                 = "https://download.opensuse.org/distribution/leap/16.0/offline/Leap-16.0-online-installer-aarch64.install.iso"
# iso_checksum            = "file:https://download.opensuse.org/distribution/leap/16.0/offline/Leap-16.0-online-installer-aarch64.install.iso.sha256"
parallels_guest_os_type = "opensuse"
vbox_guest_os_type      = "OpenSUSE_Leap_arm64"
vmware_guest_os_type    = "arm-other-64"
utm_vm_icon             = "suse"
# boot_command            = ["<wait><down><wait>e<wait><down><down><down><down><end> agama.ay_check=0 inst.auto=http://{{ .HTTPIP }}:{{ .HTTPPort }}/opensuse/autoinst-uefi.xml<wait><f10><wait>"]
# boot_command = [
#   "<wait><down><wait>e<wait><down><down><down><down><end><wait>",
#   " inst.auto=http://{{ .HTTPIP }}:{{ .HTTPPort }}/opensuse/agama-profile-uefi.jsonnet<wait>",
#   "<f10><wait>"
# ]
boot_command = [
  "<wait>",
  "<down><wait>e<wait>",
  "<down><down><down><down><end><wait>",
  # " net.ifnames=0 biosdevname=0",
  # " ip=dhcp<wait>",
  # " systemd.journald.forward_to_console=1<wait>",
  # " console=tty0<wait>",
  " inst.auto=http://{{ .HTTPIP }}:{{ .HTTPPort }}/opensuse/agama-profile-uefi.json<wait>",
  "<leftCtrlOn><wait>x<wait><leftCtrlOff>"
]
