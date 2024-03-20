os_name                 = "amazonlinux"
os_version              = "2"
os_arch                 = "aarch64"
vbox_source_path        = "https://cdn.amazonlinux.com/os-images/latest/kvm-arm64/amzn2-kvm-2.0.20240306.2-arm64.xfs.gpt.qcow2"
vbox_checksum           = "file:https://cdn.amazonlinux.com/os-images/latest/kvm-arm64/SHA256SUMS"
parallels_guest_os_type = "fedora-core"
vbox_guest_os_type      = "Fedora_64"
vmware_guest_os_type    = "arm-fedora-64"
sources_enabled = [
  "source.virtualbox-ovf.vm"
]
