os_name         = "amazonlinux"
os_version      = "2"
os_arch         = "aarch64"
iso_url         = "https://cdn.amazonlinux.com/os-images/2.0.20240131.0/kvm-arm64/amzn2-kvm-2.0.20240131.0-arm64.xfs.gpt.qcow2"
iso_checksum    = "file:https://cdn.amazonlinux.com/os-images/2.0.20240131.0/kvm-arm64/SHA256SUMS"
qemu_disk_image = true
sources_enabled = [
  "source.qemu.vm"
]
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "arm-rhel9-64"
