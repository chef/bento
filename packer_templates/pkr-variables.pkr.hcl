# General variables
variable "os_name" {
  type        = string
  description = "OS Brand Name"
}
variable "os_version" {
  type        = string
  description = "OS version number"
}
variable "os_arch" {
  type = string
  validation {
    condition     = var.os_arch == "x86_64" || var.os_arch == "aarch64"
    error_message = "The OS architecture type should be either x86_64 or aarch64."
  }
  description = "OS architecture type, x86_64 or aarch64"
}
variable "is_windows" {
  type        = bool
  default     = false
  description = "Determines to set setting for Windows or Linux"
}
variable "http_proxy" {
  type        = string
  default     = env("http_proxy")
  description = "Http proxy url to connect to the internet"
}
variable "https_proxy" {
  type        = string
  default     = env("https_proxy")
  description = "Https proxy url to connect to the internet"
}
variable "no_proxy" {
  type        = string
  default     = env("no_proxy")
  description = "No Proxy"
}
variable "sources_enabled" {
  type = list(string)
  default = [
    "source.parallels-iso.vm",
    "source.qemu.vm",
    "source.virtualbox-iso.vm",
    "source.vmware-iso.vm",
  ]
  description = "Build Sources to use for building vagrant boxes"
}

# Source block provider specific variables
# hyperv-iso
variable "hyperv_boot_wait" {
  type    = string
  default = null
}
variable "hyperv_enable_dynamic_memory" {
  type    = bool
  default = null
}
variable "hyperv_enable_secure_boot" {
  type    = bool
  default = null
}
variable "hyperv_generation" {
  type        = number
  default     = 2
  description = "Hyper-v generation version"
}
variable "hyperv_guest_additions_mode" {
  type    = string
  default = "disable"
}
variable "hyperv_switch_name" {
  type    = string
  default = "bento"
}

# parallels-iso
variable "parallels_boot_wait" {
  type    = string
  default = null
}
variable "parallels_guest_os_type" {
  type        = string
  default     = null
  description = "OS type for virtualization optimization"
}
variable "parallels_tools_flavor" {
  type    = string
  default = null
}
variable "parallels_tools_mode" {
  type    = string
  default = null
}
variable "parallels_prlctl" {
  type    = list(list(string))
  default = null
}
variable "parallels_prlctl_version_file" {
  type    = string
  default = ".prlctl_version"
}

# qemu
variable "qemu_accelerator" {
  type    = string
  default = null
}
variable "qemu_binary" {
  type    = string
  default = null
}
variable "qemu_boot_wait" {
  type    = string
  default = null
}
variable "qemu_display" {
  type    = string
  default = "none"
}
variable "qemu_disk_image" {
  type        = bool
  default     = null
  description = "Whether iso_url is a bootable qcow2 disk image"
}
variable "qemu_efi_boot" {
  type        = bool
  default     = false
  description = "Enable EFI boot"
}
variable "qemu_efi_firmware_code" {
  type        = string
  default     = null
  description = "EFI firmware code path"
}
variable "qemu_efi_firmware_vars" {
  type        = string
  default     = null
  description = "EFI firmware vars file path"
}
variable "qemu_efi_drop_efivars" {
  type        = bool
  default     = false
  description = "Drop EFI vars"
}
variable "qemu_format" {
  type        = string
  default     = "qcow2"
  description = "Disk format, takes qcow2 or raw"
}
variable "qemu_machine_type" {
  type    = string
  default = null
}
variable "qemuargs" {
  type    = list(list(string))
  default = null
}

# virtualbox-iso
variable "vbox_boot_wait" {
  type    = string
  default = null
}
variable "vbox_gfx_controller" {
  type    = string
  default = null
}
variable "vbox_gfx_vram_size" {
  type    = number
  default = null
}
variable "vbox_guest_additions_interface" {
  type    = string
  default = "sata"
}
variable "vbox_guest_additions_mode" {
  type    = string
  default = null
}
variable "vbox_guest_additions_path" {
  type    = string
  default = "VBoxGuestAdditions_{{ .Version }}.iso"
}
variable "vbox_guest_os_type" {
  type        = string
  default     = null
  description = "OS type for virtualization optimization"
}
variable "vbox_hard_drive_interface" {
  type    = string
  default = "sata"
}
variable "vbox_iso_interface" {
  type    = string
  default = "sata"
}
variable "vboxmanage" {
  type = list(list(string))
  default = [
    [
      "modifyvm",
      "{{.Name}}",
      "--audio",
      "none",
      "--nat-localhostreachable1",
      "on",
    ]
  ]
}
variable "virtualbox_version_file" {
  type    = string
  default = ".vbox_version"
}

# virtualbox-ovf
variable "vbox_source_path" {
  type        = string
  default     = null
  description = "Path to the OVA/OVF file"
}
variable "vbox_checksum" {
  type        = string
  default     = null
  description = "Checksum of the OVA/OVF file"
}

# vmware-iso
variable "vmware_boot_wait" {
  type    = string
  default = null
}
variable "vmware_cdrom_adapter_type" {
  type        = string
  default     = "sata"
  description = "CDROM adapter type.  Needs to be SATA (or non-SCSI) for ARM64 builds."
}
variable "vmware_disk_adapter_type" {
  type        = string
  default     = "sata"
  description = "Disk adapter type.  Needs to be SATA (PVSCSI, or non-SCSI) for ARM64 builds."
}
variable "vmware_guest_os_type" {
  type        = string
  default     = null
  description = "OS type for virtualization optimization"
}
variable "vmware_tools_upload_flavor" {
  type    = string
  default = null
}
variable "vmware_tools_upload_path" {
  type    = string
  default = null
}
variable "vmware_version" {
  type    = number
  default = 21
}
variable "vmware_vmx_data" {
  type = map(string)
  default = {
    # "firmware"                = "efi"
    "cpuid.coresPerSocket"    = "2"
    "ethernet0.pciSlotNumber" = "32"
    "svga.autodetect"         = true
    "usb_xhci.present"        = true
  }
}
variable "vmware_vmx_remove_ethernet_interfaces" {
  type    = bool
  default = true
}
variable "vmware_enable_usb" {
  type    = bool
  default = true
}
variable "vmware_network_adapter_type" {
  type    = string
  default = "e1000e"
}
variable "vmware_network" {
  type    = string
  default = "nat"
}

# Source block common variables
variable "boot_command" {
  type        = list(string)
  default     = null
  description = "Commands to pass to gui session to initiate automated install"
}
variable "default_boot_wait" {
  type    = string
  default = null
}
variable "cd_files" {
  type    = list(string)
  default = null
}
variable "cpus" {
  type    = number
  default = 2
}
variable "communicator" {
  type    = string
  default = null
}
variable "disk_size" {
  type    = number
  default = 65536
}
variable "floppy_files" {
  type    = list(string)
  default = null
}
variable "headless" {
  type        = bool
  default     = true
  description = "Start GUI window to interact with VM"
}
variable "http_directory" {
  type    = string
  default = null
}
variable "iso_checksum" {
  type        = string
  default     = null
  description = "ISO download checksum"
}
variable "iso_url" {
  type        = string
  default     = null
  description = "ISO download url"
}
variable "memory" {
  type    = number
  default = null
}
variable "output_directory" {
  type    = string
  default = null
}
variable "shutdown_command" {
  type    = string
  default = null
}
variable "shutdown_timeout" {
  type    = string
  default = "15m"
}
variable "ssh_password" {
  type    = string
  default = "vagrant"
}
variable "ssh_port" {
  type    = number
  default = 22
}
variable "ssh_timeout" {
  type    = string
  default = "30m"
}
variable "ssh_username" {
  type    = string
  default = "vagrant"
}
variable "winrm_password" {
  type    = string
  default = "vagrant"
}
variable "winrm_timeout" {
  type    = string
  default = "60m"
}
variable "winrm_username" {
  type    = string
  default = "vagrant"
}
variable "vm_name" {
  type    = string
  default = null
}

# builder common block
variable "scripts" {
  type    = list(string)
  default = null
}
