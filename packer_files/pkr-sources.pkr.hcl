locals {
  boot_command    = "<up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${substr(var.os_version, 0, 1)}/ks.cfg<enter><wait>"
  build_timestamp = "${formatdate("'v'YYYY'.'MM'.'DD'.0'", timestamp())}"
  memory          = var.is_windows ? 4096 : 2048
}

# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "hyperv-iso" "hyperv" {
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
source "parallels-iso" "parallels" {
  guest_os_type          = "centos"
  parallels_tools_flavor = "lin"
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
source "qemu" "qemu" {
  headless = true
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
source "virtualbox-iso" "virtualbox" {
  guest_additions_path    = "VBoxGuestAdditions_{{ .Version }}.iso"
  guest_additions_url     = ""
  guest_os_type           = "RedHat_64"
  hard_drive_interface    = "sata"
  headless                = true
  virtualbox_version_file = ".vbox_version"
  vboxmanage = [
    [
      "modifyvm",
      "{{.Name}}",
      "--nat-localhostreachable1",
      "on",
      "--graphicscontroller",
      "vmsvga",
      "--vram",
      "33"
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
source "vmware-iso" "vmware" {
  guest_os_type       = "centos-64"
  headless            = true
  tools_upload_flavor = var.is_windows ? "windows" : "linux"
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
