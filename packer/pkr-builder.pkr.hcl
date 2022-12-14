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
    libvirt = {
      version = ">= 0.0.1"
      source = "github.com/hashicorp/libvirt"
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
      source = "github.com/hashicorp/vmware"
    }
    windows-update = {
      version = ">= 0.14.1"
      source = "github.com/rgl/windows-update"
    }
  }
}

locals {
  boot_command = "<up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.ks_path}<enter><wait>"
  build_timestamp = "${}"
  http_directory  = "${path.root}/http"
}

# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "null" "vm" {
  boot_wait            = "5s"
  cpus                 = 2
  disk_size            = 65536
  http_directory       = "${local.http_directory}"
  iso_checksum         = "${var.iso_checksum}"
  iso_url              = "${var.mirror}/${var.mirror_directory}/${var.iso_name}"
  memory               = "${var.memory}"
  output_directory     = "${var.build_directory}/packer-${var.template}-${source.type}"
  shutdown_command     = "echo 'vagrant' | sudo -S /sbin/halt -h -p"
  ssh_password         = "vagrant"
  ssh_port             = 22
  ssh_timeout          = "10000s"
  ssh_username         = "vagrant"
  vm_name              = "${var.template}"
}

# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  source "null.vm" {
    name = "hyperv"
    type = "hyperv-iso"
    boot_command = ["<wait5><up><wait5><tab> text ks=hd:fd0:/ks.cfg<enter><wait5><esc>"]
    floppy_files = ["${local.http_directory}/${var.ks_path}"]
    generation           = "${var.hyperv_generation}"
    guest_additions_mode = "disable"
    switch_name          = "${var.hyperv_switch}"
  }
  source "null.vm" {
    name = "libvirt"
    type = "libvirt"
    libvirt_uri = "qemu:///system"
  }
  source "null.vm" {
    name = "parallels"
    type = "parallels-iso"
    boot_command = "${boot_command}"
    guest_os_type          = "centos"
    parallels_tools_flavor = "lin"
    prlctl                 = [["set", "{{ .Name }}", "--3d-accelerate", "off"], ["set", "{{ .Name }}", "--videosize", "16"]]
    prlctl_version_file    = ".prlctl_version"
  }
  source "null.vm" {
    name = "qemu"
    type = "qemu"
    headless         = "${var.headless}"
    qemuargs         = [["-m", "${var.memory}"], ["-display", "${var.qemu_display}"]]
  }
  source "null.vm" {
    name = "virtualbox"
    type = "virtualbox-iso"
    guest_additions_path    = "VBoxGuestAdditions_{{ .Version }}.iso"
    guest_additions_url     = "${var.guest_additions_url}"
    guest_os_type           = "RedHat_64"
    hard_drive_interface    = "sata"
    headless                = "${var.headless}"
    virtualbox_version_file = ".vbox_version"
  }
  source "null.vm" {
    name = "vmware"
    type = "vmware-iso"
    guest_os_type       = "centos-64"
    headless            = "${var.headless}"
    tools_upload_flavor = "linux"
    version             = 19
    vmx_data = {
      "cpuid.coresPerSocket" = "1"
    }
    vmx_remove_ethernet_interfaces = true
  }

  provisioner "shell" {
    environment_vars  = ["HOME_DIR=/home/vagrant", "http_proxy=${var.http_proxy}", "https_proxy=${var.https_proxy}", "no_proxy=${var.no_proxy}"]
    execute_command   = "echo 'vagrant' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    expect_disconnect = true
    scripts           = ["${path.root}/scripts/update.sh", "${path.root}/../_common/motd.sh", "${path.root}/../_common/sshd.sh", "${path.root}/../_common/vagrant.sh", "${path.root}/../_common/virtualbox.sh", "${path.root}/../_common/vmware.sh", "${path.root}/../_common/parallels.sh", "${path.root}/scripts/cleanup.sh", "${path.root}/../_common/minimize.sh"]
  }

  post-processor "vagrant" {
    output = "${var.build_directory}/${var.box_basename}.{{ .Provider }}.box"
  }
}
