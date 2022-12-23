locals {
  boot_command        = var.boot_command != null ? [replace(var.boot_command, "#{os_major_version}", substr(var.os_version, 0, 1))] : null
  boot_command_hyperv = var.boot_command_hyperv != null ? [replace(var.boot_command_hyperv, "#{os_major_version}", substr(var.os_version, 0, 1))] : null
  build_timestamp     = "${formatdate("'v'YYYY'.'MM'.'DD'.0'", timestamp())}"
  memory              = var.is_windows ? 4096 : 1024
}

# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "hyperv-iso" "vm" {
  boot_command          = var.is_windows ? null : local.boot_command_hyperv
  enable_dynamic_memory = var.hyperv_generation == 2 && var.is_windows ? "true" : null
  enable_secure_boot    = var.hyperv_generation == 2 && var.is_windows ? false : null
  floppy_files = var.hyperv_generation == 2 ? null : (
    var.is_windows ? [
      "${path.root}/answer_files/${var.os_version}/Autounattend.xml",
      "${path.root}/scripts/base_setup.ps1"
      ] : [
      "${path.root}/http/rhel/${substr(var.os_version, 0, 1)}ks.cfg"
    ]
  )
  generation           = var.hyperv_generation
  guest_additions_mode = "disable"
  switch_name          = "bento"
  headless             = var.headless
  boot_wait            = "5s"
  cpus                 = 2
  communicator         = var.is_windows ? "winrm" : "ssh"
  disk_size            = 65536
  http_directory       = "${path.root}/http"
  iso_checksum         = var.iso_checksum
  iso_url              = var.iso_url
  memory               = local.memory
  output_directory     = "${path.root}/../builds/packer-${var.os_name}-${var.os_version}-${var.os_arch}-${source.type}"
  shutdown_command     = var.is_windows ? "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\"" : "echo 'vagrant' | sudo -S /sbin/halt -h -p"
  shutdown_timeout     = var.is_windows ? "15m" : null
  ssh_password         = "vagrant"
  ssh_port             = 22
  ssh_timeout          = "10000s"
  ssh_username         = "vagrant"
  winrm_password       = "vagrant"
  winrm_timeout        = "12h"
  winrm_username       = "vagrant"
  vm_name              = "${var.os_name}-${var.os_version}-${var.os_arch}"
}
source "parallels-iso" "vm" {
  guest_os_type = var.parallels_guest_os_type
  floppy_files = var.is_windows ? [
    "${path.root}/answer_files/${var.os_version}/Autounattend.xml",
    "${path.root}/scripts/base_setup.ps1"
  ] : null
  parallels_tools_flavor = var.is_windows ? (
    var.os_arch == "x86_64" ? "win" : "win-arm"
    ) : (
    var.os_arch == "x86_64" ? "lin" : "lin-arm"
  )
  parallels_tools_mode = var.is_windows ? "attach" : "upload"
  prlctl = var.is_windows ? [
    ["set", "{{ .Name }}", "--efi-boot", "off"]
    ] : [
    ["set", "{{ .Name }}", "--3d-accelerate", "off"],
    ["set", "{{ .Name }}", "--videosize", "16"]
  ]
  prlctl_version_file = ".prlctl_version"
  boot_command        = var.is_windows && var.os_version == 10 ? null : local.boot_command
  boot_wait           = "5s"
  cpus                = 2
  communicator        = var.is_windows ? "winrm" : "ssh"
  disk_size           = 65536
  http_directory      = "${path.root}/http"
  iso_checksum        = var.iso_checksum
  iso_url             = var.iso_url
  memory              = local.memory
  output_directory    = "${path.root}/../builds/packer-${var.os_name}-${var.os_version}-${var.os_arch}-${source.type}"
  shutdown_command    = var.is_windows ? "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\"" : "echo 'vagrant' | sudo -S /sbin/halt -h -p"
  shutdown_timeout    = var.is_windows ? "15m" : null
  ssh_password        = "vagrant"
  ssh_port            = 22
  ssh_timeout         = "10000s"
  ssh_username        = "vagrant"
  winrm_password      = "vagrant"
  winrm_timeout       = "12h"
  winrm_username      = "vagrant"
  vm_name             = "${var.os_name}-${var.os_version}-${var.os_arch}"
}
source "qemu" "vm" {
  accelerator = "kvm"
  headless    = var.headless
  cd_files    = var.hyperv_generation == 2 && var.is_windows ? ["${path.root}/answer_files/${substr(var.os_version, 0, 2)}/Autounattend.xml"] : null
  floppy_files = var.hyperv_generation == 2 && var.is_windows ? null : (
    var.is_windows ? [
      "${path.root}/answer_files/${var.os_version}/Autounattend.xml",
      "${path.root}/scripts/base_setup.ps1"
    ] : null
  )
  qemuargs = var.hyperv_generation == 2 && var.is_windows ? [
    ["-m", "${local.memory}"],
    ["-smp", "2"],
    ["-bios", "/usr/share/OVMF/OVMF_CODE.fd"],
    ["-display", "none"]
    ] : (
    var.is_windows ? [
      ["-m", "${local.memory}"],
      ["-smp", "2"],
      ["-drive", "file=~/virtio-win.iso,media=cdrom,index=3"],
      ["-drive", "file=${path.root}/../builds/packer-${var.os_name}-${var.os_version}-qemu/{{ .Name }},if=virtio,cache=writeback,discard=ignore,format=qcow2,index=1"],
      ["-display", "none"]
      ] : [
      ["-m", "${local.memory}"],
      ["-display", "none"]
    ]
  )
  boot_command     = var.is_windows ? null : local.boot_command
  boot_wait        = "5s"
  cpus             = 2
  communicator     = var.is_windows ? "winrm" : "ssh"
  disk_size        = 65536
  http_directory   = "${path.root}/http"
  iso_checksum     = var.iso_checksum
  iso_url          = var.iso_url
  memory           = local.memory
  output_directory = "${path.root}/../builds/packer-${var.os_name}-${var.os_version}-${var.os_arch}-${source.type}"
  shutdown_command = var.is_windows ? "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\"" : "echo 'vagrant' | sudo -S /sbin/halt -h -p"
  shutdown_timeout = var.is_windows ? "15m" : null
  ssh_password     = "vagrant"
  ssh_port         = 22
  ssh_timeout      = "10000s"
  ssh_username     = "vagrant"
  winrm_password   = "vagrant"
  winrm_timeout    = "12h"
  winrm_username   = "vagrant"
  vm_name          = "${var.os_name}-${var.os_version}-${var.os_arch}"
}
source "virtualbox-iso" "vm" {
  gfx_controller            = var.is_windows ? "vboxsvga" : "vmsvga"
  gfx_vram_size             = var.is_windows ? 128 : 33
  guest_additions_path      = "VBoxGuestAdditions_{{ .Version }}.iso"
  guest_additions_mode      = var.is_windows && var.hyperv_generation == 1 ? "attach" : "upload"
  guest_additions_interface = "sata"
  guest_os_type             = var.vbox_guest_os_type
  hard_drive_interface      = "sata"
  headless                  = var.headless
  floppy_files = var.is_windows ? [
    "${path.root}/answer_files/${var.os_version}/Autounattend.xml",
    "${path.root}/scripts/base_setup.ps1"
  ] : null
  virtualbox_version_file = ".vbox_version"
  vboxmanage = [
    [
      "modifyvm",
      "{{.Name}}",
      "--audio",
      "none",
#      "--nat-localhostreachable1",
#      "on",
    ]
  ]
  iso_interface    = "sata"
  boot_command     = var.is_windows ? null : local.boot_command
  boot_wait        = "5s"
  cpus             = 2
  communicator     = var.is_windows ? "winrm" : "ssh"
  disk_size        = 65536
  http_directory   = "${path.root}/http"
  iso_checksum     = var.iso_checksum
  iso_url          = var.iso_url
  memory           = local.memory
  output_directory = "${path.root}/../builds/packer-${var.os_name}-${var.os_version}-${var.os_arch}-${source.type}"
  shutdown_command = var.is_windows ? "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\"" : "echo 'vagrant' | sudo -S /sbin/halt -h -p"
  shutdown_timeout = var.is_windows ? "15m" : null
  ssh_password     = "vagrant"
  ssh_port         = 22
  ssh_timeout      = "10000s"
  ssh_username     = "vagrant"
  winrm_password   = "vagrant"
  winrm_timeout    = "12h"
  winrm_username   = "vagrant"
  vm_name          = "${var.os_name}-${var.os_version}-${var.os_arch}"
}
source "virtualbox-ovf" "amazonlinux" {
  guest_additions_path = "VBoxGuestAdditions_{{ .Version }}.iso"
  headless             = var.headless
  vboxmanage = [
    [
      "modifyvm",
      "{{ .Name }}",
      "--memory",
      "${local.memory}",
      "--cpus", "2",
      "--nat-localhostreachable1",
      "on",
    ]
  ]
  source_path             = "${path.root}/amz_working_files/amazon2.ovf"
  http_directory          = "${path.root}/http"
  output_directory        = "${path.root}/../builds/packer-${var.os_name}-${var.os_version}-${var.os_arch}-${source.type}"
  shutdown_command        = "echo 'vagrant' | sudo -S /sbin/halt -h -p"
  ssh_password            = "vagrant"
  ssh_port                = 22
  ssh_timeout             = "10000s"
  ssh_username            = "vagrant"
  virtualbox_version_file = ".vbox_version"
  vm_name                 = "${var.os_name}-${var.os_version}-${var.os_arch}"
}
source "vmware-iso" "vm" {
  guest_os_type     = var.vmware_guest_os_type
  disk_adapter_type = var.is_windows ? "lsisas1068" : null
  headless          = var.headless
  floppy_files = var.is_windows ? [
    "${path.root}/answer_files/${var.os_version}/Autounattend.xml",
    "${path.root}/scripts/base_setup.ps1"
  ] : null
  tools_upload_flavor = var.is_windows ? "windows" : null
  tools_upload_path   = var.is_windows ? "c:/Windows/Temp/vmware.iso" : null
  version             = 19
  vmx_data = {
    "cpuid.coresPerSocket" = "1"
  }
  vmx_remove_ethernet_interfaces = true
  boot_command                   = var.is_windows ? null : local.boot_command
  boot_wait                      = "5s"
  cpus                           = 2
  communicator                   = var.is_windows ? "winrm" : "ssh"
  disk_size                      = 65536
  http_directory                 = "${path.root}/http"
  iso_checksum                   = var.iso_checksum
  iso_url                        = var.iso_url
  memory                         = local.memory
  output_directory               = "${path.root}/../builds/packer-${var.os_name}-${var.os_version}-${var.os_arch}-${source.type}"
  shutdown_command               = var.is_windows ? "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\"" : "echo 'vagrant' | sudo -S /sbin/halt -h -p"
  shutdown_timeout               = var.is_windows ? "15m" : null
  ssh_password                   = "vagrant"
  ssh_port                       = 22
  ssh_timeout                    = "10000s"
  ssh_username                   = "vagrant"
  winrm_password                 = "vagrant"
  winrm_timeout                  = "12h"
  winrm_username                 = "vagrant"
  vm_name                        = "${var.os_name}-${var.os_version}-${var.os_arch}"
}
