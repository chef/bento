locals {
  # Source block provider specific
  # hyperv-iso
  hyperv_enable_dynamic_memory = var.hyperv_enable_dynamic_memory == null ? (
    var.hyperv_generation == 2 && var.is_windows ? true : false
  ) : var.hyperv_enable_dynamic_memory
  hyperv_enable_secure_boot = var.hyperv_enable_secure_boot == null ? (
    var.hyperv_generation == 2 && var.is_windows ? true : false
  ) : var.hyperv_enable_secure_boot

  # parallels-iso
  parallels_tools_flavor = var.parallels_tools_flavor == null ? (
    var.is_windows ? (
      var.os_arch == "x86_64" ? "win" : "win-arm"
      ) : (
      var.os_arch == "x86_64" ? "lin" : "lin-arm"
    )
  ) : var.parallels_tools_flavor
  parallels_tools_mode = var.parallels_tools_mode == null ? (
    var.is_windows ? "attach" : "upload"
  ) : var.parallels_tools_mode
  parallels_prlctl = var.parallels_prlctl == null ? (
    var.is_windows ? (
      var.os_arch == "x86_64" ? [
        ["set", "{{ .Name }}", "--efi-boot", "off"]
        ] : [
        ["set", "{{ .Name }}", "--efi-boot", "off"],
        ["set", "{{ .Name }}", "--efi-secure-boot", "off"],
        ["set", "{{ .Name }}", "--device-add", "cdrom", "--image", "${path.root}/../builds/iso/unattended.iso", "--connect"],
      ]
      ) : [
      ["set", "{{ .Name }}", "--3d-accelerate", "off"],
      ["set", "{{ .Name }}", "--videosize", "16"]
    ]
  ) : var.parallels_prlctl

  # qemu
  qemu_binary  = var.qemu_binary == null ? "qemu-system-${var.os_arch}" : var.qemu_binary
  qemu_display = var.qemu_display == null ? "none" : var.qemu_display
  qemu_use_default_display = var.qemu_use_default_display == null ? (
    var.os_arch == "aarch64" ? true : false
  ) : var.qemu_use_default_display
  qemu_machine_type = var.qemu_machine_type == null ? (
    var.os_arch == "aarch64" ? "virt" : "q35"
  ) : var.qemu_machine_type
  qemuargs = var.qemuargs == null ? (
    var.is_windows ? [
      ["-drive", "file=${path.root}/../builds/iso/virtio-win.iso,media=cdrom,index=3"],
      ["-drive", "file=${var.iso_url},media=cdrom,index=2"],
      ["-drive", "file=${path.root}/../builds/build_files/packer-${var.os_name}-${var.os_version}-${var.os_arch}-qemu/{{ .Name }},if=virtio,cache=writeback,discard=ignore,format=${var.qemu_format},index=1"],
      ] : (
      var.os_arch == "aarch64" ? [
        ["-boot", "strict=off"]
        # ["-cpu", "host"],
        # ["-monitor", "stdio"]
      ] : null
    )
  ) : var.qemuargs

  # virtualbox-iso
  vbox_gfx_controller = var.vbox_gfx_controller == null ? (
    var.is_windows ? "vboxsvga" : "vmsvga"
  ) : var.vbox_gfx_controller
  vbox_gfx_vram_size = var.vbox_gfx_controller == null ? (
    var.is_windows ? 128 : 33
  ) : var.vbox_gfx_vram_size
  vbox_guest_additions_mode = var.vbox_guest_additions_mode == null ? (
    var.is_windows ? "attach" : "upload"
  ) : var.vbox_guest_additions_mode

  # vmware-iso
  vmware_tools_upload_flavor = var.vmware_tools_upload_flavor == null ? (
    var.is_windows ? "windows" : "linux"
  ) : var.vmware_tools_upload_flavor
  vmware_tools_upload_path = var.vmware_tools_upload_path == null ? (
    var.is_windows ? "c:\\vmware-tools.iso" : "/tmp/vmware-tools.iso"
  ) : var.vmware_tools_upload_path

  # Source block common
  default_boot_wait = var.default_boot_wait == null ? (
    var.is_windows ? "60s" : (
      var.os_name == "macos" ? "8m" : "5s"
    )
  ) : var.default_boot_wait
  cd_files = var.cd_files == null ? (
    var.is_windows ? (
      var.hyperv_generation == 2 ? [
        "${path.root}/win_answer_files/${var.os_version}/hyperv-gen2/Autounattend.xml",
        ] : (
        var.os_arch == "x86_64" ? [
          "${path.root}/win_answer_files/${var.os_version}/Autounattend.xml",
          ] : [
          "${path.root}/win_answer_files/${var.os_version}/arm64/Autounattend.xml",
        ]
      )
    ) : null
  ) : var.cd_files
  communicator = var.communicator == null ? (
    var.is_windows ? "winrm" : "ssh"
  ) : var.communicator
  floppy_files = var.floppy_files == null ? (
    var.is_windows ? (
      var.os_arch == "x86_64" ? [
        "${path.root}/win_answer_files/${var.os_version}/Autounattend.xml",
        ] : [
        "${path.root}/win_answer_files/${var.os_version}/arm64/Autounattend.xml",
      ]
    ) : null
  ) : var.floppy_files
  http_directory = var.http_directory == null ? "${path.root}/http" : var.http_directory
  memory = var.memory == null ? (
    var.is_windows || var.os_name == "macos" ? 4096 : 2048
  ) : var.memory
  output_directory = var.output_directory == null ? "${path.root}/../builds/build_files/packer-${var.os_name}-${var.os_version}-${var.os_arch}" : var.output_directory
  shutdown_command = var.shutdown_command == null ? (
    var.is_windows ? "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\"" : (
      var.os_name == "macos" ? "echo 'vagrant' | sudo -S shutdown -h now" : (
        var.os_name == "freebsd" ? "echo 'vagrant' | su -m root -c 'shutdown -p now'" : "echo 'vagrant' | sudo -S /sbin/halt -h -p"
      )
    )
  ) : var.shutdown_command
  vm_name = var.vm_name == null ? (
    var.os_arch == "x86_64" ? "${var.os_name}-${var.os_version}-amd64" : "${var.os_name}-${var.os_version}-${var.os_arch}"
  ) : var.vm_name
}

# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "hyperv-iso" "vm" {
  # Hyper-v specific options
  enable_dynamic_memory = local.hyperv_enable_dynamic_memory
  enable_secure_boot    = local.hyperv_enable_secure_boot
  generation            = var.hyperv_generation
  guest_additions_mode  = var.hyperv_guest_additions_mode
  switch_name           = var.hyperv_switch_name
  # Source block common options
  boot_command     = var.boot_command
  boot_wait        = var.hyperv_boot_wait == null ? local.default_boot_wait : var.hyperv_boot_wait
  cd_files         = var.hyperv_generation == 2 ? local.cd_files : null
  cpus             = var.cpus
  communicator     = local.communicator
  disk_size        = var.disk_size
  floppy_files     = var.hyperv_generation == 2 ? null : local.floppy_files
  headless         = var.headless
  http_directory   = local.http_directory
  iso_checksum     = var.iso_checksum
  iso_url          = var.iso_url
  memory           = local.memory
  output_directory = "${local.output_directory}-hyperv"
  shutdown_command = local.shutdown_command
  shutdown_timeout = var.shutdown_timeout
  ssh_password     = var.ssh_password
  ssh_port         = var.ssh_port
  ssh_timeout      = var.ssh_timeout
  ssh_username     = var.ssh_username
  winrm_password   = var.winrm_password
  winrm_timeout    = var.winrm_timeout
  winrm_username   = var.winrm_username
  vm_name          = local.vm_name
}
source "parallels-ipsw" "vm" {
  # Parallels specific options
  host_interfaces     = var.parallels_host_interfaces
  ipsw_url            = var.parallels_ipsw_url
  ipsw_checksum       = var.parallels_ipsw_checksum
  prlctl              = local.parallels_prlctl
  prlctl_post         = var.parallels_prlctl_post
  prlctl_version_file = var.parallels_prlctl_version_file
  # Source block common options
  boot_command     = var.boot_command
  boot_wait        = var.parallels_boot_wait == null ? local.default_boot_wait : var.parallels_boot_wait
  cpus             = var.cpus
  communicator     = local.communicator
  disk_size        = var.disk_size
  http_directory   = local.http_directory
  http_content     = var.http_content
  memory           = local.memory
  output_directory = "${local.output_directory}-parallels"
  shutdown_command = local.shutdown_command
  shutdown_timeout = var.shutdown_timeout
  ssh_password     = var.ssh_password
  ssh_port         = var.ssh_port
  ssh_timeout      = var.ssh_timeout
  ssh_username     = var.ssh_username
  vm_name          = local.vm_name
}
source "parallels-iso" "vm" {
  # Parallels specific options
  guest_os_type          = var.parallels_guest_os_type
  parallels_tools_flavor = local.parallels_tools_flavor
  parallels_tools_mode   = local.parallels_tools_mode
  prlctl                 = local.parallels_prlctl
  prlctl_version_file    = var.parallels_prlctl_version_file
  # Source block common options
  boot_command     = var.boot_command
  boot_wait        = var.parallels_boot_wait == null ? local.default_boot_wait : var.parallels_boot_wait
  cpus             = var.cpus
  communicator     = local.communicator
  disk_size        = var.disk_size
  floppy_files     = local.floppy_files
  http_directory   = local.http_directory
  iso_checksum     = var.iso_checksum
  iso_url          = var.iso_url
  memory           = local.memory
  output_directory = "${local.output_directory}-parallels"
  shutdown_command = local.shutdown_command
  shutdown_timeout = var.shutdown_timeout
  ssh_password     = var.ssh_password
  ssh_port         = var.ssh_port
  ssh_timeout      = var.ssh_timeout
  ssh_username     = var.ssh_username
  winrm_password   = var.winrm_password
  winrm_timeout    = var.winrm_timeout
  winrm_username   = var.winrm_username
  vm_name          = local.vm_name
}
source "qemu" "vm" {
  # QEMU specific options
  accelerator         = var.qemu_accelerator
  display             = local.qemu_display
  use_default_display = local.qemu_use_default_display
  disk_image          = var.qemu_disk_image
  efi_boot            = var.qemu_efi_boot
  efi_firmware_code   = var.qemu_efi_firmware_code
  efi_firmware_vars   = var.qemu_efi_firmware_vars
  efi_drop_efivars    = var.qemu_efi_drop_efivars
  format              = var.qemu_format
  machine_type        = local.qemu_machine_type
  qemu_binary         = local.qemu_binary
  qemuargs            = local.qemuargs
  # Source block common options
  boot_command     = var.boot_command
  boot_wait        = var.qemu_boot_wait == null ? local.default_boot_wait : var.qemu_boot_wait
  cd_files         = local.cd_files
  cpus             = var.cpus
  communicator     = local.communicator
  disk_size        = var.disk_size
  floppy_files     = local.floppy_files
  headless         = var.headless
  http_directory   = local.http_directory
  iso_checksum     = var.iso_checksum
  iso_url          = var.iso_url
  memory           = local.memory
  output_directory = "${local.output_directory}-qemu"
  shutdown_command = local.shutdown_command
  shutdown_timeout = var.shutdown_timeout
  ssh_password     = var.ssh_password
  ssh_port         = var.ssh_port
  ssh_timeout      = var.ssh_timeout
  ssh_username     = var.ssh_username
  winrm_password   = var.winrm_password
  winrm_timeout    = var.winrm_timeout
  winrm_username   = var.winrm_username
  vm_name          = local.vm_name
}
source "virtualbox-iso" "vm" {
  # Virtualbox specific options
  #firmware                  = "efi"
  gfx_controller            = local.vbox_gfx_controller
  gfx_vram_size             = local.vbox_gfx_vram_size
  guest_additions_path      = var.vbox_guest_additions_path
  guest_additions_mode      = local.vbox_guest_additions_mode
  guest_additions_interface = var.vbox_guest_additions_interface
  guest_os_type             = var.vbox_guest_os_type
  hard_drive_interface      = var.vbox_hard_drive_interface
  iso_interface             = var.vbox_iso_interface
  vboxmanage                = var.vboxmanage
  virtualbox_version_file   = var.virtualbox_version_file
  # Source block common options
  boot_command     = var.boot_command
  boot_wait        = var.vbox_boot_wait == null ? local.default_boot_wait : var.vbox_boot_wait
  cpus             = var.cpus
  communicator     = local.communicator
  disk_size        = var.disk_size
  floppy_files     = local.floppy_files
  headless         = var.headless
  http_directory   = local.http_directory
  iso_checksum     = var.iso_checksum
  iso_url          = var.iso_url
  memory           = local.memory
  output_directory = "${local.output_directory}-virtualbox"
  shutdown_command = local.shutdown_command
  shutdown_timeout = var.shutdown_timeout
  ssh_password     = var.ssh_password
  ssh_port         = var.ssh_port
  ssh_timeout      = var.ssh_timeout
  ssh_username     = var.ssh_username
  winrm_password   = var.winrm_password
  winrm_timeout    = var.winrm_timeout
  winrm_username   = var.winrm_username
  vm_name          = local.vm_name
}
source "virtualbox-ovf" "vm" {
  # Virtualbox specific options
  guest_additions_path    = var.vbox_guest_additions_path
  source_path             = var.vbox_source_path
  checksum                = var.vbox_checksum
  vboxmanage              = var.vboxmanage
  virtualbox_version_file = var.virtualbox_version_file
  # Source block common options
  communicator     = local.communicator
  headless         = var.headless
  output_directory = "${local.output_directory}-virtualbox-ovf"
  shutdown_command = local.shutdown_command
  shutdown_timeout = var.shutdown_timeout
  ssh_password     = var.ssh_password
  ssh_port         = var.ssh_port
  ssh_timeout      = var.ssh_timeout
  ssh_username     = var.ssh_username
  vm_name          = local.vm_name
}
source "vmware-iso" "vm" {
  # VMware specific options
  cdrom_adapter_type             = var.vmware_cdrom_adapter_type
  disk_adapter_type              = var.vmware_disk_adapter_type
  guest_os_type                  = var.vmware_guest_os_type
  network                        = var.vmware_network
  network_adapter_type           = var.vmware_network_adapter_type
  tools_upload_flavor            = local.vmware_tools_upload_flavor
  tools_upload_path              = local.vmware_tools_upload_path
  usb                            = var.vmware_enable_usb
  version                        = var.vmware_version
  vmx_data                       = var.vmware_vmx_data
  vmx_remove_ethernet_interfaces = var.vmware_vmx_remove_ethernet_interfaces
  # Source block common options
  boot_command     = var.boot_command
  boot_wait        = var.vmware_boot_wait == null ? local.default_boot_wait : var.vmware_boot_wait
  cpus             = var.cpus
  communicator     = local.communicator
  disk_size        = var.disk_size
  floppy_files     = local.floppy_files
  headless         = var.headless
  http_directory   = local.http_directory
  iso_checksum     = var.iso_checksum
  iso_url          = var.iso_url
  memory           = local.memory
  output_directory = "${local.output_directory}-vmware"
  shutdown_command = local.shutdown_command
  shutdown_timeout = var.shutdown_timeout
  ssh_password     = var.ssh_password
  ssh_port         = var.ssh_port
  ssh_timeout      = var.ssh_timeout
  ssh_username     = var.ssh_username
  winrm_password   = var.winrm_password
  winrm_timeout    = var.winrm_timeout
  winrm_username   = var.winrm_username
  vm_name          = local.vm_name
}
