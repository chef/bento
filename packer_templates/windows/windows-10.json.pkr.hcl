
variable "build_directory" {
  type    = string
  default = "../../builds"
}

variable "cpus" {
  type    = string
  default = "2"
}

variable "disk_size" {
  type    = string
  default = "40000"
}

variable "guest_additions_mode" {
  type    = string
  default = "attach"
}

variable "guest_additions_url" {
  type    = string
  default = ""
}

variable "headless" {
  type    = string
  default = "true"
}

variable "hyperv_switch" {
  type    = string
  default = "bento"
}

variable "iso_checksum" {
  type    = string
  default = "489ebee676e26cdb81377b0e6385c001a22589b8"
}

variable "iso_url" {
  type    = string
  default = "https://software-download.microsoft.com/download/pr/18363.418.191007-0143.19h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
}

variable "memory" {
  type    = string
  default = "4096"
}

variable "qemu_display" {
  type    = string
  default = "none"
}

variable "template" {
  type    = string
  default = "windows-10"
}

variable "unattended_file_path" {
  type    = string
  default = "10/Autounattend.xml"
}

variable "virtio_win_iso" {
  type    = string
  default = "~/virtio-win.iso"
}

locals {
  floppy_dir = "${path.root}/answer_files"
}

source "hyperv-iso" "autogenerated_1" {
  communicator     = "winrm"
  cpus             = "${var.cpus}"
  disk_size        = "${var.disk_size}"
  floppy_files     = ["${local.floppy_dir}/${var.unattended_file_path}", "${path.root}/scripts/base_setup.ps1"]
  headless         = "${var.headless}"
  iso_checksum     = "${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  memory           = "${var.memory}"
  output_directory = "${var.build_directory}/packer-${var.template}-virtualbox"
  shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  shutdown_timeout = "15m"
  switch_name      = "${var.hyperv_switch}"
  winrm_password   = "vagrant"
  winrm_timeout    = "12h"
  winrm_username   = "vagrant"
}

source "parallels-iso" "autogenerated_2" {
  communicator           = "winrm"
  cpus                   = "${var.cpus}"
  disk_size              = "${var.disk_size}"
  floppy_files           = ["${local.floppy_dir}/${var.unattended_file_path}", "${path.root}/scripts/base_setup.ps1"]
  guest_os_type          = "win-10"
  iso_checksum           = "${var.iso_checksum}"
  iso_url                = "${var.iso_url}"
  memory                 = "${var.memory}"
  output_directory       = "${var.build_directory}/packer-${var.template}-parallels"
  parallels_tools_flavor = "win"
  parallels_tools_mode   = "attach"
  prlctl                 = [["set", "{{ .Name }}", "--efi-boot", "off"]]
  prlctl_version_file    = ".prlctl_version"
  shutdown_command       = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  shutdown_timeout       = "15m"
  winrm_password         = "vagrant"
  winrm_timeout          = "12h"
  winrm_username         = "vagrant"
}

source "qemu" "autogenerated_3" {
  communicator     = "winrm"
  cpus             = "${var.cpus}"
  disk_size        = "${var.disk_size}"
  floppy_files     = ["${local.floppy_dir}/${var.unattended_file_path}", "${path.root}/scripts/base_setup.ps1"]
  headless         = "${var.headless}"
  iso_checksum     = "${var.iso_checksum}"
  iso_url          = "${var.iso_url}"
  memory           = "${var.memory}"
  output_directory = "${var.build_directory}/packer-${var.template}-qemu"
  qemuargs         = [["-m", "${var.memory}"], ["-smp", "${var.cpus}"], ["-drive", "file=${var.virtio_win_iso},media=cdrom,index=3"], ["-drive", "file=${var.build_directory}/packer-${var.template}-qemu/{{ .Name }},if=virtio,cache=writeback,discard=ignore,format=qcow2,index=1"], ["-display", "${var.qemu_display}"]]
  shutdown_command = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  shutdown_timeout = "15m"
  winrm_password   = "vagrant"
  winrm_timeout    = "12h"
  winrm_username   = "vagrant"
}

source "virtualbox-iso" "autogenerated_4" {
  communicator              = "winrm"
  cpus                      = "${var.cpus}"
  disk_size                 = "${var.disk_size}"
  floppy_files              = ["${local.floppy_dir}/${var.unattended_file_path}", "${path.root}/scripts/base_setup.ps1"]
  guest_additions_interface = "sata"
  guest_additions_mode      = "${var.guest_additions_mode}"
  guest_additions_path      = "C:/users/vagrant/VBoxGuestAdditions.iso"
  guest_additions_url       = "${var.guest_additions_url}"
  guest_os_type             = "Windows10_64"
  hard_drive_interface      = "sata"
  headless                  = "${var.headless}"
  iso_checksum              = "${var.iso_checksum}"
  iso_interface             = "ide"
  iso_url                   = "${var.iso_url}"
  memory                    = "${var.memory}"
  output_directory          = "${var.build_directory}/packer-${var.template}-virtualbox"
  shutdown_command          = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  shutdown_timeout          = "15m"
  vboxmanage                = [["modifyvm", "{{ .Name }}", "--vram", "48"], ["modifyvm", "{{ .Name }}", "--audio", "none"]]
  winrm_password            = "vagrant"
  winrm_timeout             = "12h"
  winrm_username            = "vagrant"
}

source "vmware-iso" "autogenerated_5" {
  communicator        = "winrm"
  cpus                = "${var.cpus}"
  disk_adapter_type   = "lsisas1068"
  disk_size           = "${var.disk_size}"
  floppy_files        = ["${local.floppy_dir}/${var.unattended_file_path}", "${path.root}/scripts/base_setup.ps1"]
  guest_os_type       = "windows9srv-64"
  headless            = "${var.headless}"
  iso_checksum        = "${var.iso_checksum}"
  iso_url             = "${var.iso_url}"
  memory              = "${var.memory}"
  output_directory    = "${var.build_directory}/packer-${var.template}-vmware"
  shutdown_command    = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\""
  shutdown_timeout    = "15m"
  tools_upload_flavor = "windows"
  tools_upload_path   = "c:/Windows/Temp/vmware.iso"
  version             = 19
  winrm_password      = "vagrant"
  winrm_timeout       = "12h"
  winrm_username      = "vagrant"
}

build {
  sources = ["source.hyperv-iso.autogenerated_1", "source.parallels-iso.autogenerated_2", "source.qemu.autogenerated_3", "source.virtualbox-iso.autogenerated_4", "source.vmware-iso.autogenerated_5"]

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
    run_list       = ["packer::cleanup", "packer::defrag"]
  }

  provisioner "powershell" {
    elevated_password = "vagrant"
    elevated_user     = "vagrant"
    script            = "${path.root}/scripts/cleanup.ps1"
  }

  post-processor "vagrant" {
    keep_input_artifact  = true
    output               = "${var.build_directory}/${var.template}-<no value>.box"
    vagrantfile_template = "${path.root}/vagrantfile-windows.template"
  }
}
