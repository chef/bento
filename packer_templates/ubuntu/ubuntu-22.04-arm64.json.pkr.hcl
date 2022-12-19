
variable "box_basename" {
  type    = string
  default = "ubuntu-22.04-arm64"
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
  default = "2"
}

variable "hyperv_switch" {
  type    = string
  default = "bento"
}

variable "iso_checksum" {
  type    = string
  default = "bc5a8015651c6f8699ab262d333375d3930b824f03d14ae51e551d89d9bb571c"
}

variable "iso_name" {
  type    = string
  default = "ubuntu-22.04.1-live-server-arm64.iso"
}

variable "memory" {
  type    = string
  default = "1024"
}

variable "mirror" {
  type    = string
  default = "http://cdimage.ubuntu.com"
}

variable "mirror_directory" {
  type    = string
  default = "releases/22.04/release"
}

variable "name" {
  type    = string
  default = "ubuntu-22.04-arm64"
}

variable "no_proxy" {
  type    = string
  default = "${env("no_proxy")}"
}

variable "preseed_path" {
  type    = string
  default = "preseed.cfg"
}

variable "template" {
  type    = string
  default = "ubuntu-22.04-arm64"
}

variable "version" {
  type    = string
  default = "TIMESTAMP"
}
# The "legacy_isotime" function has been provided for backwards compatability, but we recommend switching to the timestamp and formatdate functions.

locals {
  build_timestamp = "${legacy_isotime("20060102150405")}"
  http_directory  = "${path.root}/http"
}

source "parallels-iso" "autogenerated_1" {
  boot_command           = ["<wait5>", "c", "<wait>", "set gfxpayload=keep<enter>", "<wait>", "linux /casper/vmlinuz", " quiet", " autoinstall", " ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'", "<enter>", "initrd /casper/initrd<enter>", "boot<enter>"]
  boot_wait              = "5s"
  cpus                   = "${var.cpus}"
  disk_size              = "${var.disk_size}"
  guest_os_type          = "ubuntu"
  http_directory         = "${local.http_directory}"
  iso_checksum           = "${var.iso_checksum}"
  iso_url                = "${var.mirror}/${var.mirror_directory}/${var.iso_name}"
  memory                 = "${var.memory}"
  output_directory       = "${var.build_directory}/packer-${var.template}-parallels"
  parallels_tools_flavor = "lin-arm"
  prlctl_version_file    = ".prlctl_version"
  shutdown_command       = "echo 'vagrant' | sudo -S shutdown -P now"
  ssh_password           = "vagrant"
  ssh_port               = 22
  ssh_timeout            = "10000s"
  ssh_username           = "vagrant"
  vm_name                = "${var.template}"
}

build {
  sources = ["source.parallels-iso.autogenerated_1"]

  provisioner "shell" {
    environment_vars  = ["HOME_DIR=/home/vagrant", "http_proxy=${var.http_proxy}", "https_proxy=${var.https_proxy}", "no_proxy=${var.no_proxy}"]
    execute_command   = "echo 'vagrant' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    expect_disconnect = true
    scripts           = ["${path.root}/scripts/update.sh", "${path.root}/../_common/motd.sh", "${path.root}/../_common/sshd.sh", "${path.root}/scripts/networking.sh", "${path.root}/scripts/sudoers.sh", "${path.root}/scripts/vagrant.sh", "${path.root}/../_common/virtualbox.sh", "${path.root}/scripts/vmware.sh", "${path.root}/../_common/parallels.sh", "${path.root}/scripts/hyperv.sh", "${path.root}/scripts/cleanup.sh", "${path.root}/../_common/minimize.sh"]
  }

  post-processor "vagrant" {
    output = "${var.build_directory}/${var.box_basename}.{{ .Provider }}.box"
  }
}
