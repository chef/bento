locals {
  boot_command    = "<up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${substr(var.os_version, 0, 1)}/ks.cfg<enter><wait>"
  build_timestamp = "${formatdate("'v'YYYY'.'MM'.'DD'.0'", timestamp())}"
  memory          = var.is_windows ? 2048 : 1024
}

# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "hyperv-iso" "vm" {
  boot_command = [
    "<wait5><up><wait5><tab> text ks=hd:fd0:/ks.cfg<enter><wait5><esc>"
  ]
  floppy_files = [
    "${path.root}/http/${substr(var.os_version, 0, 1)}/ks.cfg"
  ]
  generation           = "${var.hyperv_generation}"
  guest_additions_mode = "disable"
  switch_name          = "bento"
  boot_wait            = "5s"
  cpus                 = 2
  disk_size            = 65536
  http_directory       = "${path.root}/http"
  iso_checksum         = var.iso_checksum
  iso_url              = var.iso_url
  memory               = local.memory
  output_directory     = "${path.root}/../builds/packer-${var.os_name}-${var.os_version}-${var.os_arch}-${source.type}"
  shutdown_command     = "echo 'vagrant' | sudo -S /sbin/halt -h -p"
  ssh_password         = "vagrant"
  ssh_port             = 22
  ssh_timeout          = "10000s"
  ssh_username         = "vagrant"
  vm_name              = "${var.os_name}-${var.os_version}-${var.os_arch}"
}
#source "libvirt" "libvert" {
#  libvirt_uri = "qemu:///system"
#  boot_command = [
#    local.boot_command
#  ]
#  boot_wait            = "5s"
#  cpus                 = 2
#  disk_size            = 65536
#  http_directory       = "${path.root}/http"
#  iso_checksum         = var.iso_checksum
#  iso_url              = var.iso_url
#  memory               = local.memory
#  output_directory     = "${path.root}/../builds/packer-${var.os_name}-${var.os_version}-${var.os_arch}-${source.type}"
#  shutdown_command     = "echo 'vagrant' | sudo -S /sbin/halt -h -p"
#  ssh_password         = "vagrant"
#  ssh_port             = 22
#  ssh_timeout          = "10000s"
#  ssh_username         = "vagrant"
#  vm_name              = "${var.os_name}-${var.os_version}-${var.os_arch}"
#}
source "parallels-iso" "vm" {
  guest_os_type          = var.parallels_os_type
  parallels_tools_flavor = var.is_windows ? "win" : "lin"
  prlctl = [
    [
      "set",
      "{{ .Name }}",
      "--3d-accelerate",
      "off"
    ],
    [
      "set",
      "{{ .Name }}",
      "--videosize",
      "16"
    ]
  ]
  prlctl_version_file = ".prlctl_version"
  boot_command = [
    local.boot_command
  ]
  boot_wait        = "5s"
  cpus             = 2
  disk_size        = 65536
  http_directory   = "${path.root}/http"
  iso_checksum     = var.iso_checksum
  iso_url          = var.iso_url
  memory           = local.memory
  output_directory = "${path.root}/../builds/packer-${var.os_name}-${var.os_version}-${var.os_arch}-${source.type}"
  shutdown_command = "echo 'vagrant' | sudo -S /sbin/halt -h -p"
  ssh_password     = "vagrant"
  ssh_port         = 22
  ssh_timeout      = "10000s"
  ssh_username     = "vagrant"
  vm_name          = "${var.os_name}-${var.os_version}-${var.os_arch}"
}
source "qemu" "vm" {
  headless    = true
  accelerator = "kvm"
  qemuargs = [
    [
      "-m", "${local.memory}"
    ],
    [
      "-display", "none"
    ]
  ]
  boot_command = [
    local.boot_command
  ]
  boot_wait        = "5s"
  cpus             = 2
  disk_size        = 65536
  http_directory   = "${path.root}/http"
  iso_checksum     = var.iso_checksum
  iso_url          = var.iso_url
  memory           = local.memory
  output_directory = "${path.root}/../builds/packer-${var.os_name}-${var.os_version}-${var.os_arch}-${source.type}"
  shutdown_command = "echo 'vagrant' | sudo -S /sbin/halt -h -p"
  ssh_password     = "vagrant"
  ssh_port         = 22
  ssh_timeout      = "10000s"
  ssh_username     = "vagrant"
  vm_name          = "${var.os_name}-${var.os_version}-${var.os_arch}"
}
source "virtualbox-iso" "vm" {
  gfx_controller          = "vboxsvga"
  gfx_vram_size           = var.is_windows ? 99 : 33
  guest_additions_path    = "VBoxGuestAdditions_{{ .Version }}.iso"
  guest_os_type           = var.vbox_guest_os_type
  hard_drive_interface    = "sata"
  headless                = true
  virtualbox_version_file = ".vbox_version"
  vboxmanage = [
    [
      "modifyvm",
      "{{.Name}}",
      "--nat-localhostreachable1",
      "on",
    ]
  ]
  boot_command = [
    local.boot_command
  ]
  boot_wait        = "5s"
  cpus             = 2
  disk_size        = 65536
  http_directory   = "${path.root}/http"
  iso_checksum     = var.iso_checksum
  iso_url          = var.iso_url
  iso_interface    = "sata"
  memory           = local.memory
  output_directory = "${path.root}/../builds/packer-${var.os_name}-${var.os_version}-${var.os_arch}-${source.type}"
  shutdown_command = "echo 'vagrant' | sudo -S /sbin/halt -h -p"
  ssh_password     = "vagrant"
  ssh_port         = 22
  ssh_timeout      = "10000s"
  ssh_username     = "vagrant"
  vm_name          = "${var.os_name}-${var.os_version}-${var.os_arch}"
}
source "virtualbox-ovf" "amazonlinux" {
  guest_additions_path = "VBoxGuestAdditions_{{ .Version }}.iso"
  headless             = true
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
  guest_os_type       = var.vmware_guest_os_type
  headless            = true
  tools_upload_flavor = var.is_windows ? "windows" : null
  version             = 19
  vmx_data = {
    "cpuid.coresPerSocket" = "1"
  }
  vmx_remove_ethernet_interfaces = true
  boot_command = [
    local.boot_command
  ]
  boot_wait        = "5s"
  cpus             = 2
  disk_size        = 65536
  http_directory   = "${path.root}/http"
  iso_checksum     = var.iso_checksum
  iso_url          = var.iso_url
  memory           = local.memory
  output_directory = "${path.root}/../builds/packer-${var.os_name}-${var.os_version}-${var.os_arch}-${source.type}"
  shutdown_command = "echo 'vagrant' | sudo -S /sbin/halt -h -p"
  ssh_password     = "vagrant"
  ssh_port         = 22
  ssh_timeout      = "10000s"
  ssh_username     = "vagrant"
  vm_name          = "${var.os_name}-${var.os_version}-${var.os_arch}"
}
