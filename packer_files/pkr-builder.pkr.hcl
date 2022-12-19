packer {
  required_version = ">= 1.7.0"
  required_plugins {
    hyperv = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/hyperv"
    }
    inspec = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/inspec"
    }
    parallels = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/parallels"
    }
    qemu = {
      version = ">= 1.0.8"
      source  = "github.com/hashicorp/qemu"
    }
    vagrant = {
      version = ">= 1.0.2"
      source  = "github.com/hashicorp/vagrant"
    }
    virtualbox = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/virtualbox"
    }
    vmware = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/vmware"
    }
    windows-update = {
      version = ">= 0.14.1"
      source  = "github.com/rgl/windows-update"
    }
  }
}

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
  description = "Determines to set setting for Windows or Linux"
}
variable "iso_url" {
  type        = string
  default     = null
  description = "ISO download url"
}
variable "iso_checksum" {
  type        = string
  default     = null
  description = "ISO download checksum"
}
variable "hyperv_generation" {
  type        = number
  default     = 1
  description = "Hyper-v generation version"
}
variable "parallels_guest_os_type" {
  type        = string
  default     = null
  description = "OS type for virtualization optimization"
}
variable "vbox_guest_os_type" {
  type        = string
  default     = null
  description = "OS type for virtualization optimization"
}
variable "vmware_guest_os_type" {
  type        = string
  default     = null
  description = "OS type for virtualization optimization"
}

locals {
  shell_scripts = var.is_windows ? [
    "${path.root}/scripts/cleanup.ps1"
    ] : (
    "${var.os_name}-${substr(var.os_version, 0, 1)}" == "amazonliunux-2" ||
    "${var.os_name}-${substr(var.os_version, 0, 1)}" == "centos-7" ||
    "${var.os_name}-${substr(var.os_version, 0, 1)}" == "oraclelinux-7" ||
    "${var.os_name}-${substr(var.os_version, 0, 1)}" == "rhel-7" ||
    "${var.os_name}-${substr(var.os_version, 0, 1)}" == "scientificlinux-7" ||
    "${var.os_name}-${substr(var.os_version, 0, 1)}" == "springdalelinux-7" ? [
      "${path.root}/scripts/update_yum.sh",
      "${path.root}/_common/motd.sh",
      "${path.root}/_common/sshd.sh",
      "${path.root}/scripts/networking.sh",
      "${path.root}/_common/vagrant.sh",
      "${path.root}/_common/virtualbox.sh",
      "${path.root}/_common/vmware.sh",
      "${path.root}/_common/parallels.sh",
      "${path.root}/scripts/cleanup_yum.sh",
      "${path.root}/_common/minimize.sh"
      ] : [
      "${path.root}/scripts/update_dnf.sh",
      "${path.root}/_common/motd.sh",
      "${path.root}/_common/sshd.sh",
      "${path.root}/_common/vagrant.sh",
      "${path.root}/_common/virtualbox.sh",
      "${path.root}/_common/vmware.sh",
      "${path.root}/_common/parallels.sh",
      "${path.root}/scripts/cleanup_dnf.sh",
      "${path.root}/_common/minimize.sh"
    ]
  )
}

# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = [
    "source.hyperv-iso.vm",
    # "source.libvirt.vm",
    "source.parallels-iso.vm",
    "source.qemu.vm",
    "source.virtualbox-iso.vm",
    "source.virtualbox-ovf.amazonlinux",
    "source.vmware-iso.vm"
  ]

  provisioner "shell" {
    environment_vars = [
      "HOME_DIR=/home/vagrant"
    ]
    execute_command   = "echo 'vagrant' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    expect_disconnect = true
    scripts           = local.shell_scripts
  }

  post-processor "vagrant" {
    output = "${path.root}/../builds/${var.os_name}-${var.os_version}-${var.os_arch}.{{ .Provider }}.box"
  }
}
