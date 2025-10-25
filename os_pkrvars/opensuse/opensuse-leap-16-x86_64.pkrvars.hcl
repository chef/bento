os_name                 = "opensuse-leap"
os_version              = "16.0"
os_arch                 = "x86_64"
iso_url                 = "https://download.opensuse.org/distribution/leap/16.0/installer/iso/agama-installer.x86_64-Leap_16.0.iso"
iso_checksum            = "file:https://download.opensuse.org/distribution/leap/16.0/installer/iso/agama-installer.x86_64-Leap_16.0.iso.sha256"
parallels_guest_os_type = "opensuse"
parallels_boot_wait     = "1s"
vbox_guest_os_type      = "OpenSUSE_Leap_64"
vmware_guest_os_type    = "opensuse-64"
utm_vm_icon             = "suse"
boot_command = [
  "<wait>",
  "<down><wait>e<wait>",
  "<down><down><down><down><end><wait>",
  " inst.auto=http://{{ .HTTPIP }}:{{ .HTTPPort }}/opensuse/agama-profile.json<wait>",
  "<leftCtrlOn><wait>x<wait><leftCtrlOff>"
]
