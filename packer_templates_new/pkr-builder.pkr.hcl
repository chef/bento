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
variable "boot_command" {
  type        = string
  default     = null
  description = "Commands to pass to gui session to initiate automated install"
}
variable "boot_command_hyperv" {
  type        = string
  default     = null
  description = "Commands to pass to gui session to initiate automated install"
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
variable "headless" {
  type        = bool
  default     = true
  description = "Start GUI window to interact with VM"
}
variable "sources_enabled" {
  type = list(string)
  default = [
    "source.hyperv-iso.vm",
    # "source.libvirt.vm",
    "source.parallels-iso.vm",
    "source.qemu.vm",
    "source.virtualbox-iso.vm",
    "source.vmware-iso.vm",
  ]
  description = "Build Sources to use for building vagrant boxes"
}

locals {
  shell_scripts = var.is_windows ? [
    "${path.root}/scripts/cleanup.ps1"
    ] : (
    var.os_name == "ubuntu" ||
    var.os_name == "debian" ? [
      "${path.root}/scripts/update_apt.sh",
      "${path.root}/_common/motd.sh",
      "${path.root}/_common/sshd.sh",
      "${path.root}/scripts/networking_ubuntu.sh",
      "${path.root}/scripts/sudoers_ubuntu.sh",
      "${path.root}/_common/vagrant.sh",
      "${path.root}/_common/virtualbox.sh",
      "${path.root}/_common/vmware_ubuntu.sh",
      "${path.root}/_common/parallels.sh",
      "${path.root}/scripts/hyperv_ubuntu.sh",
      "${path.root}/scripts/cleanup_apt.sh",
      "${path.root}/_common/minimize.sh"
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
        "${path.root}/scripts/networking_rhel7.sh",
        "${path.root}/_common/vagrant.sh",
        "${path.root}/_common/virtualbox.sh",
        "${path.root}/_common/vmware_rhel.sh",
        "${path.root}/_common/parallels.sh",
        "${path.root}/scripts/cleanup_yum.sh",
        "${path.root}/_common/minimize.sh"
        ] : [
        "${path.root}/scripts/update_dnf.sh",
        "${path.root}/_common/motd.sh",
        "${path.root}/_common/sshd.sh",
        "${path.root}/_common/vagrant.sh",
        "${path.root}/_common/virtualbox.sh",
        "${path.root}/_common/vmware_rhel.sh",
        "${path.root}/_common/parallels.sh",
        "${path.root}/scripts/cleanup_dnf.sh",
        "${path.root}/_common/minimize.sh"
      ]
    )
  )
  source_names = [for source in var.sources_enabled : trimprefix(source, "source.")]
}

# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = var.sources_enabled

  # Linux Shell scipts
  provisioner "shell" {
    environment_vars = [
      "HOME_DIR=/home/vagrant"
    ]
    execute_command   = "echo 'vagrant' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    expect_disconnect = true
    scripts           = local.shell_scripts
    except            = var.is_windows ? local.source_names : null
  }

  # Windows Updates and scripts
  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    filters = [
      "exclude:$_.Title -like '*Preview*'",
      "include:$true",
    ]
    only = var.is_windows ? local.source_names : null
  }
  provisioner "chef-solo" {
    chef_license = "accept-no-persist"
    version = "17"
    cookbook_paths = [
      "${path.root}/cookbooks"
    ]
    guest_os_type = "windows"
    run_list = [
      "packer::disable_uac",
      "packer::disable_restore",
      "packer::disable_windows_update",
      "packer::configure_power",
      "packer::disable_screensaver"
    ]
    only = var.is_windows ? local.source_names : null
  }
  provisioner "windows-restart" {
    only = var.is_windows ? local.source_names : null
  }
  provisioner "chef-solo" {
    chef_license = "accept-no-persist"
    version = "17"
    cookbook_paths = [
      "${path.root}/cookbooks"
    ]
    guest_os_type = "windows"
    run_list = [
      "packer::vm_tools",
      "packer::features",
      "packer::enable_file_sharing",
      "packer::enable_remote_desktop",
      "packer::ui_tweaks"
    ]
    only = var.is_windows ? local.source_names : null
  }
  provisioner "windows-restart" {
    only = var.is_windows ? local.source_names : null
  }
  provisioner "chef-solo" {
    chef_license = "accept-no-persist"
    version = "17"
    cookbook_paths = [
      "${path.root}/cookbooks"
    ]
    guest_os_type = "windows"
    run_list = [
      "packer::cleanup",
      "packer::defrag"
    ]
    only = var.is_windows ? local.source_names : null
  }
  provisioner "powershell" {
    elevated_password = "vagrant"
    elevated_user     = "vagrant"
    script            = "${path.root}/scripts/cleanup.ps1"
    timeout = "5m"
    only              = var.is_windows ? local.source_names : null
  }

  # Convert machines to vagrant boxes
  post-processor "vagrant" {
    keep_input_artifact  = var.is_windows
    output               = "${path.root}/../builds/${var.os_name}-${var.os_version}-${var.os_arch}.{{ .Provider }}.box"
    vagrantfile_template = var.is_windows ? (var.hyperv_generation == 1 ? "${path.root}/vagrantfile-windows.template" : "${path.root}/vagrantfile-windows-gen2.template") : null
  }
}
