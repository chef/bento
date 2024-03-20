os_name                = "amazonlinux"
os_version             = "2023"
os_arch                = "aarch64"
iso_url                = "https://cdn.amazonlinux.com/al2023/os-images/2023.3.20240131.0/kvm-arm64/al2023-kvm-2023.3.20240131.0-kernel-6.1-arm64.xfs.gpt.qcow2"
iso_checksum           = "file:https://cdn.amazonlinux.com/al2023/os-images/2023.3.20240131.0/kvm-arm64/SHA256SUMS"
qemu_disk_image        = true
cd_files               = ["/Users/corey.hemminger/Documents/github/personal/chef/cookbooks/testing/bento/packer_templates/amz_seed_iso/*"]
qemu_efi_boot          = true
qemu_efi_firmware_code = "/opt/homebrew/Cellar/qemu/8.2.1/share/qemu/edk2-arm-code.fd"
qemu_efi_firmware_vars = "/opt/homebrew/Cellar/qemu/8.2.1/share/qemu/edk2-arm-vars.fd"
qemu_efi_drop_efivars  = null
sources_enabled = [
  "source.qemu.vm"
]
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "arm-rhel9-64"
