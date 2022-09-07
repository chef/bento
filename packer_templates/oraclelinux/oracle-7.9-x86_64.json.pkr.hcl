
variable "arch" {
  type    = string
  default = "64"
}

variable "box_basename" {
  type    = string
  default = "oracle-7.9"
}

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
  default = "65536"
}

variable "git_revision" {
  type    = string
  default = "__unknown_git_revision__"
}

variable "guest_additions_url" {
  type    = string
  default = ""
}

variable "headless" {
  type    = string
  default = ""
}

variable "http_proxy" {
  type    = string
  default = "${env("http_proxy")}"
}

variable "https_proxy" {
  type    = string
  default = "${env("https_proxy")}"
}

variable "hyperv_generation" {
  type    = string
  default = "1"
}

variable "hyperv_switch" {
  type    = string
  default = "bento"
}

variable "iso_checksum" {
  type    = string
  default = "dc2782bfd92b4c060cf8006fbc6e18036c27f599eebf3584a1a2ac54f008bf2f"
}

variable "iso_name" {
  type    = string
  default = "OracleLinux-R7-U9-Server-x86_64-dvd.iso"
}

variable "ks_path" {
  type    = string
  default = "7/ks.cfg"
}

variable "memory" {
  type    = string
  default = "1024"
}

variable "mirror" {
  type    = string
  default = "http://mirrors.dotsrc.org/oracle-linux"
}

variable "mirror_directory" {
  type    = string
  default = "OL7/u9/x86_64"
}

variable "name" {
  type    = string
  default = "oracle-7.9"
}

variable "no_proxy" {
  type    = string
  default = "${env("no_proxy")}"
}

variable "qemu_display" {
  type    = string
  default = "none"
}

variable "template" {
  type    = string
  default = "oracle-7.9-x86_64"
}

variable "version" {
  type    = string
  default = "TIMESTAMP"
}
# The "legacy_isotime" function has been provided for backwards compatability, but we recommend switching to the timestamp and formatdate functions.

locals {
  build_timestamp = "${legacy_isotime("20060102150405")}"
  http_directory  = "${path.root}/../centos/http"
}

source "hyperv-iso" "autogenerated_1" {
  boot_command         = ["<wait5><tab> text ks=hd:fd0:/ks.cfg net.ifnames=0 biosdevname=0<enter><wait5><esc>"]
  boot_wait            = "5s"
  cpus                 = "${var.cpus}"
  disk_size            = "${var.disk_size}"
  floppy_files         = ["${local.http_directory}/${var.ks_path}"]
  generation           = "${var.hyperv_generation}"
  guest_additions_mode = "disable"
  http_directory       = "${local.http_directory}"
  iso_checksum         = "${var.iso_checksum}"
  iso_url              = "${var.mirror}/${var.mirror_directory}/${var.iso_name}"
  memory               = "${var.memory}"
  output_directory     = "${var.build_directory}/packer-${var.template}-hyperv"
  shutdown_command     = "echo 'vagrant' | sudo -S /sbin/halt -h -p"
  ssh_password         = "vagrant"
  ssh_port             = 22
  ssh_timeout          = "10000s"
  ssh_username         = "vagrant"
  switch_name          = "${var.hyperv_switch}"
  vm_name              = "${var.template}"
}

source "parallels-iso" "autogenerated_2" {
  boot_command           = ["<up><wait><tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.ks_path} net.ifnames=0 biosdevname=0<enter><wait>"]
  boot_wait              = "5s"
  cpus                   = "${var.cpus}"
  disk_size              = "${var.disk_size}"
  guest_os_type          = "centos"
  http_directory         = "${local.http_directory}"
  iso_checksum           = "${var.iso_checksum}"
  iso_url                = "${var.mirror}/${var.mirror_directory}/${var.iso_name}"
  memory                 = "${var.memory}"
  output_directory       = "${var.build_directory}/packer-${var.template}-parallels"
  parallels_tools_flavor = "lin"
  prlctl                 = [["set", "{{ .Name }}", "--3d-accelerate", "off"], ["set", "{{ .Name }}", "--videosize", "16"]]
  prlctl_version_file    = ".prlctl_version"
  shutdown_command       = "echo 'vagrant' | sudo -S /sbin/halt -h -p"
  ssh_password           = "vagrant"
  ssh_port               = 22
  ssh_timeout            = "10000s"
  ssh_username           = "vagrant"
  vm_name                = "${var.template}"
}

source "qemu" "autogenerated_3" {
  boot_command     = ["<up><wait><tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.ks_path} net.ifnames=0 biosdevname=0<enter><wait>"]
  boot_wait        = "5s"
  cpus             = "${var.cpus}"
  disk_size        = "${var.disk_size}"
  headless         = "${var.headless}"
  http_directory   = "${local.http_directory}"
  iso_checksum     = "${var.iso_checksum}"
  iso_url          = "${var.mirror}/${var.mirror_directory}/${var.iso_name}"
  memory           = "${var.memory}"
  output_directory = "${var.build_directory}/packer-${var.template}-qemu"
  qemuargs         = [["-m", "${var.memory}"], ["-display", "${var.qemu_display}"]]
  shutdown_command = "echo 'vagrant'|sudo -S /sbin/halt -h -p"
  ssh_password     = "vagrant"
  ssh_port         = 22
  ssh_timeout      = "10000s"
  ssh_username     = "vagrant"
  vm_name          = "${var.template}"
}

source "virtualbox-iso" "autogenerated_4" {
  boot_command            = ["<up><wait><tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.ks_path} net.ifnames=0 biosdevname=0<enter><wait>"]
  boot_wait               = "5s"
  cpus                    = "${var.cpus}"
  disk_size               = "${var.disk_size}"
  guest_additions_path    = "VBoxGuestAdditions_{{ .Version }}.iso"
  guest_additions_url     = "${var.guest_additions_url}"
  guest_os_type           = "Oracle_64"
  hard_drive_interface    = "sata"
  headless                = "${var.headless}"
  http_directory          = "${local.http_directory}"
  iso_checksum            = "${var.iso_checksum}"
  iso_url                 = "${var.mirror}/${var.mirror_directory}/${var.iso_name}"
  memory                  = "${var.memory}"
  output_directory        = "${var.build_directory}/packer-${var.template}-virtualbox"
  shutdown_command        = "echo 'vagrant' | sudo -S /sbin/halt -h -p"
  ssh_password            = "vagrant"
  ssh_port                = 22
  ssh_timeout             = "10000s"
  ssh_username            = "vagrant"
  virtualbox_version_file = ".vbox_version"
  vm_name                 = "${var.template}"
}

source "vmware-iso" "autogenerated_5" {
  boot_command        = ["<up><wait><tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.ks_path} net.ifnames=0 biosdevname=0 <enter><wait>"]
  boot_wait           = "5s"
  cpus                = "${var.cpus}"
  disk_size           = "${var.disk_size}"
  guest_os_type       = "oraclelinux-64"
  headless            = "${var.headless}"
  http_directory      = "${local.http_directory}"
  iso_checksum        = "${var.iso_checksum}"
  iso_url             = "${var.mirror}/${var.mirror_directory}/${var.iso_name}"
  memory              = "${var.memory}"
  output_directory    = "${var.build_directory}/packer-${var.template}-vmware"
  shutdown_command    = "echo 'vagrant' | sudo -S /sbin/halt -h -p"
  ssh_password        = "vagrant"
  ssh_port            = 22
  ssh_timeout         = "10000s"
  ssh_username        = "vagrant"
  tools_upload_flavor = "linux"
  vm_name             = "${var.template}"
  vmx_data = {
    "cpuid.coresPerSocket" = "1"
  }
  vmx_remove_ethernet_interfaces = true
}

build {
  sources = ["source.hyperv-iso.autogenerated_1", "source.parallels-iso.autogenerated_2", "source.qemu.autogenerated_3", "source.virtualbox-iso.autogenerated_4", "source.vmware-iso.autogenerated_5"]

  provisioner "shell" {
    environment_vars  = ["HOME_DIR=/home/vagrant", "http_proxy=${var.http_proxy}", "https_proxy=${var.https_proxy}", "no_proxy=${var.no_proxy}"]
    execute_command   = "echo 'vagrant' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    expect_disconnect = true
    scripts           = ["${path.root}/../centos/scripts/update.sh", "${path.root}/../centos/scripts/networking.sh", "${path.root}/../_common/motd.sh", "${path.root}/../_common/sshd.sh", "${path.root}/../_common/vagrant.sh", "${path.root}/../_common/virtualbox.sh", "${path.root}/../_common/vmware.sh", "${path.root}/../_common/parallels.sh", "${path.root}/../centos/scripts/cleanup.sh", "${path.root}/../_common/minimize.sh"]
  }

  post-processor "vagrant" {
    output = "${var.build_directory}/${var.box_basename}.<no value>.box"
  }
}
