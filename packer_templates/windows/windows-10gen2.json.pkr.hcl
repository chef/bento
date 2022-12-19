
variable "autounattend" {
  type    = string
  default = "Autounattend.xml"
}

variable "boot_wait" {
  type    = string
  default = "10s"
}

variable "build_directory" {
  type    = string
  default = "../../builds"
}

variable "build_version" {
  type    = string
  default = "1"
}

variable "cpus" {
  type    = string
  default = "2"
}

variable "disk_interface" {
  type    = string
  default = "ide"
}

variable "disk_size" {
  type    = string
  default = "61440"
}

variable "disk_type_id" {
  type    = string
  default = "1"
}

variable "guest_additions_mode" {
  type    = string
  default = "upload"
}

variable "headless" {
  type    = string
  default = "false"
}

variable "hyperv_switch" {
  type    = string
  default = "bento"
}

variable "iso_checksum" {
  type    = string
  default = "F57E034095E0423FEB575CA82855F73E39FFA713"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha1"
}

variable "iso_url" {
  type    = string
  default = "https://software-download.microsoft.com/download/pr/19041.264.200511-0456.vb_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
}

variable "memory" {
  type    = string
  default = "4096"
}

variable "package_location" {
  type    = string
  default = ""
}

variable "qemu_bios" {
  type    = string
  default = "/usr/share/OVMF/OVMF_CODE.fd"
}

variable "qemu_display" {
  type    = string
  default = "none"
}

variable "restart_timeout" {
  type    = string
  default = "5m"
}

variable "sysprep_unattended" {
  type    = string
  default = ""
}

variable "template" {
  type    = string
  default = "vagrantfile-windows-gen2.template"
}

variable "template_dir" {
  type    = string
  default = ""
}

variable "unattend" {
  type    = string
  default = "answer_files\\unattend.xml"
}

variable "vagrant_sysprep_unattended" {
  type    = string
  default = ""
}

variable "vhv_enable" {
  type    = string
  default = "false"
}

variable "virtio_win_iso" {
  type    = string
  default = "virtio-win.iso"
}

variable "vm_name" {
  type    = string
  default = "windows_10"
}

variable "winrm_timeout" {
  type    = string
  default = "6h"
}

variable "working_directory" {
  type    = string
  default = ""
}

locals {
  cd_files = "${path.root}/answer_files/10/Autounattend.xml"
}

source "hyperv-iso" "autogenerated_1" {
  boot_command          = ["aaaaaaa"]
  boot_wait             = "1s"
  communicator          = "winrm"
  cpus                  = "${var.cpus}"
  enable_dynamic_memory = "true"
  enable_secure_boot    = false
  generation            = "2"
  headless              = "false"
  iso_checksum          = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url               = "${var.iso_url}"
  memory                = "${var.memory}"
  output_directory      = "c:\\packer-build\\"
  shutdown_command      = "shutdown /s /t 10 /c \"Packer Shutdown\" /f /d p:4:1"
  shutdown_timeout      = "15m"
  skip_export           = false
  switch_name           = "${var.hyperv_switch}"
  winrm_password        = "vagrant"
  winrm_timeout         = "12h"
  winrm_username        = "vagrant"
}

source "qemu" "autogenerated_2" {
  boot_command     = ["aaaaaaa<wait><enter><wait><enter><wait><enter>"]
  boot_wait        = "${var.boot_wait}"
  cd_files         = "${local.cd_files}"
  communicator     = "winrm"
  cpus             = "${var.cpus}"
  disk_interface   = "${var.disk_interface}"
  disk_size        = "${var.disk_size}"
  headless         = "${var.headless}"
  iso_checksum     = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  memory           = "${var.memory}"
  output_directory = "${var.build_directory}/packer-${var.template}-qemu"
  qemuargs         = [["-m", "${var.memory}"], ["-smp", "${var.cpus}"], ["-bios", "${var.qemu_bios}"], ["-display", "${var.qemu_display}"]]
  shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  shutdown_timeout = "15m"
  winrm_password   = "vagrant"
  winrm_timeout    = "12h"
  winrm_username   = "vagrant"
}

build {
  sources = ["source.hyperv-iso.autogenerated_1", "source.qemu.autogenerated_2"]

  provisioner "chef-solo" {
    cookbook_paths = ["${path.root}/cookbooks"]
    guest_os_type  = "windows"
    run_list       = ["packer::disable_uac", "packer::disable_restore", "packer::disable_windows_update", "packer::configure_power", "packer::disable_screensaver"]
  }

  provisioner "windows-restart" {
  }

  provisioner "chef-solo" {
    cookbook_paths = ["${path.root}/cookbooks"]
    guest_os_type  = "windows"
    run_list       = ["packer::vm_tools", "packer::features", "packer::enable_file_sharing", "packer::enable_remote_desktop", "packer::ui_tweaks"]
  }

  provisioner "windows-restart" {
  }

  provisioner "chef-solo" {
    cookbook_paths = ["${path.root}/cookbooks"]
    guest_os_type  = "windows"
    run_list       = ["packer::cleanup"]
  }

  provisioner "powershell" {
    elevated_password = "vagrant"
    elevated_user     = "vagrant"
    script            = "${path.root}/scripts/cleanup.ps1"
  }

  post-processor "vagrant" {
    keep_input_artifact  = true
    output               = "${var.build_directory}/{{ .Provider }}_windows-10.box"
    vagrantfile_template = "${path.root}/${var.template}"
  }
}
