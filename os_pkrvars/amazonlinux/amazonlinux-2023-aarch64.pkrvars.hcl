os_name                 = "amazonlinux"
os_version              = "2023"
os_arch                 = "aarch64"
vbox_source_path        = "https://cdn.amazonlinux.com/al2023/os-images/2023.3.20240312.0/vmware/al2023-vmware_esx-2023.3.20240312.0-kernel-6.1-x86_64.xfs.gpt.ova"
vbox_checksum           = "file:https://cdn.amazonlinux.com/al2023/os-images/2023.3.20240312.0/vmware/SHA256SUMS"
parallels_guest_os_type = "fedora-core"
vbox_guest_os_type      = "Fedora_64"
vmware_guest_os_type    = "arm-fedora-64"
sources_enabled = [
  "source.virtualbox-ovf.vm"
]
