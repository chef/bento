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
    condition     = var.os_arch == "x86_64" || var.os_arch == "aarm64"
    error_message = "The OS architecture type should be either x86_64 or aarm64."
  }
  description = "OS architecture type, x86_64 or aarm64"
}
variable "is_windows" {
  type = bool
}
variable "iso_url" {
  type = string
}
variable "iso_checksum" {
  type = string
}
variable "hyperv_generation" {
  type    = number
  default = 1
}

# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = [
    "source.hyperv-iso.hyperv",
    # "source.libvirt.libvirt",
    "source.parallels-iso.parallels",
    "source.qemu.qemu",
    "source.virtualbox-iso.virtualbox",
    "source.vmware-iso.vmware"
  ]

  provisioner "shell" {
    environment_vars = [
      "HOME_DIR=/home/vagrant"
    ]
    execute_command   = "echo 'vagrant' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    expect_disconnect = true
    scripts = [
      "${path.root}/scripts/update.sh",
      "${path.root}/_common/motd.sh",
      "${path.root}/_common/sshd.sh",
      "${path.root}/_common/vagrant.sh",
      "${path.root}/_common/virtualbox.sh",
      "${path.root}/_common/vmware.sh",
      "${path.root}/_common/parallels.sh",
      "${path.root}/scripts/cleanup.sh",
      "${path.root}/_common/minimize.sh"
    ]
  }

  post-processor "vagrant" {
    output = "${path.root}/../builds/${var.os_name}-${var.os_arch}.{{ .Provider }}.box"
  }
}
