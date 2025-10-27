os_name                 = "opensuse-leap"
os_version              = "16.0"
os_arch                 = "aarch64"
iso_url                 = "https://download.opensuse.org/distribution/leap/16.0/offline/Leap-16.0-online-installer-aarch64.install.iso"
iso_checksum            = "file:https://download.opensuse.org/distribution/leap/16.0/offline/Leap-16.0-online-installer-aarch64.install.iso.sha256"
parallels_guest_os_type = "opensuse"
parallels_boot_wait     = "1s"
vbox_guest_os_type      = "OpenSUSE_Leap_arm64"
vboxmanage = [
  ["modifyvm", "{{.Name}}", "--chipset", "armv8virtual"],
  ["modifyvm", "{{.Name}}", "--audio-enabled", "off"],
  ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],
  ["modifyvm", "{{.Name}}", "--cableconnected1", "on"],
  ["modifyvm", "{{.Name}}", "--usb-xhci", "on"],
  ["modifyvm", "{{.Name}}", "--mouse", "usb"],
  ["modifyvm", "{{.Name}}", "--keyboard", "usb"],
  ["storagectl", "{{.Name}}", "--name", "IDE Controller", "--remove"],
]
vmware_guest_os_type = "arm-other-64"
utm_vm_icon          = "suse"
boot_command = [
  "<down><wait>e<wait>",
  "<down><down><down><down><end><wait>",
  " inst.auto=http://{{ .HTTPIP }}:{{ .HTTPPort }}/opensuse/agama-profile.json<wait>",
  "<leftCtrlOn><wait>x<wait><leftCtrlOff>"
]
