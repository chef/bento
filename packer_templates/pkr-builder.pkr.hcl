packer {
  required_version = ">= 1.7.0"
  required_plugins {
    hyperv = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/hyperv"
    }
    parallels = {
      version = ">= 1.0.1"
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
      source  = "github.com/stromweld/vmware" # TODO: switching to stromweld repo for fix to vmware tools for fusion 13 till official fix is in place https://github.com/hashicorp/packer-plugin-vmware/issues/109
    }
    windows-update = {
      version = ">= 0.14.1"
      source  = "github.com/rgl/windows-update"
    }
  }
}

locals {
  scripts = var.is_windows ? (
    substr(var.os_version, 0, 2) == "10" ||
    substr(var.os_version, 0, 2) == "11" ? [
      # "${path.root}/scripts/windows/base_setup.ps1",
      "${path.root}/scripts/windows/provision.ps1",
      "${path.root}/scripts/windows/disable-windows-updates.ps1",
      "${path.root}/scripts/windows/disable-windows-defender.ps1",
      "${path.root}/scripts/windows/remove-one-drive.ps1",
      "${path.root}/scripts/windows/remove-apps.ps1",
      "${path.root}/scripts/windows/virtualbox-prevent-vboxsrv-resolution-delay.ps1",
      "${path.root}/scripts/windows/provision-winrm.ps1",
      "${path.root}/scripts/windows/enable-remote-desktop.ps1",
      "${path.root}/scripts/windows/eject-media.ps1"
      ] : [
      # "${path.root}/scripts/windows/base_setup.ps1",
      "${path.root}/scripts/windows/provision.ps1",
      "${path.root}/scripts/windows/disable-windows-updates.ps1",
      "${path.root}/scripts/windows/disable-windows-defender.ps1",
      "${path.root}/scripts/windows/remove-one-drive.ps1",
      # "${path.root}/scripts/windows/remove-apps.ps1",
      "${path.root}/scripts/windows/virtualbox-prevent-vboxsrv-resolution-delay.ps1",
      "${path.root}/scripts/windows/provision-winrm.ps1",
      "${path.root}/scripts/windows/enable-remote-desktop.ps1",
      "${path.root}/scripts/windows/eject-media.ps1"
    ]
    ) : (
    var.os_name == "solaris" ? [
      "${path.root}/scripts/solaris/update_solaris.sh",
      "${path.root}/scripts/_common/vagrant.sh",
      "${path.root}/scripts/solaris/vmtools_solaris.sh",
      "${path.root}/scripts/solaris/minimize_solaris.sh"
      ] : (
      var.os_name == "freebsd" ? [
        "${path.root}/scripts/freebsd/update_freebsd.sh",
        "${path.root}/scripts/freebsd/postinstall_freebsd.sh",
        "${path.root}/scripts/freebsd/sudoers_freebsd.sh",
        "${path.root}/scripts/_common/vagrant.sh",
        "${path.root}/scripts/freebsd/vmtools_freebsd.sh",
        "${path.root}/scripts/freebsd/cleanup_freebsd.sh",
        "${path.root}/scripts/freebsd/minimize_freebsd.sh"
        ] : (
        var.os_name == "opensuse" ||
        var.os_name == "sles" ? [
          "${path.root}/scripts/suse/repositories_suse.sh",
          "${path.root}/scripts/suse/update_suse.sh",
          "${path.root}/scripts/_common/motd.sh",
          "${path.root}/scripts/_common/sshd.sh",
          "${path.root}/scripts/_common/vagrant.sh",
          "${path.root}/scripts/suse/unsupported-modules_suse.sh",
          "${path.root}/scripts/_common/virtualbox.sh",
          "${path.root}/scripts/_common/vmware_suse.sh",
          "${path.root}/scripts/_common/parallels.sh",
          "${path.root}/scripts/suse/vagrant_group_suse.sh",
          "${path.root}/scripts/suse/sudoers_suse.sh",
          "${path.root}/scripts/suse/zypper-locks_suse.sh",
          "${path.root}/scripts/suse/remove-dvd-source_suse.sh",
          "${path.root}/scripts/suse/cleanup_suse.sh",
          "${path.root}/scripts/_common/minimize.sh"
          ] : (
          var.os_name == "ubuntu" ||
          var.os_name == "debian" ? [
            "${path.root}/scripts/${var.os_name}/update_${var.os_name}.sh",
            "${path.root}/scripts/_common/motd.sh",
            "${path.root}/scripts/_common/sshd.sh",
            "${path.root}/scripts/${var.os_name}/networking_${var.os_name}.sh",
            "${path.root}/scripts/${var.os_name}/sudoers_${var.os_name}.sh",
            "${path.root}/scripts/_common/vagrant.sh",
            "${path.root}/scripts/${var.os_name}/systemd_${var.os_name}.sh",
            "${path.root}/scripts/_common/virtualbox.sh",
            "${path.root}/scripts/_common/vmware_debian_ubuntu.sh",
            "${path.root}/scripts/_common/parallels.sh",
            "${path.root}/scripts/${var.os_name}/hyperv_${var.os_name}.sh",
            "${path.root}/scripts/${var.os_name}/cleanup_${var.os_name}.sh",
            "${path.root}/scripts/_common/minimize.sh"
            ] : (
            var.os_name == "fedora" ? [
              "${path.root}/scripts/fedora/networking_fedora.sh",
              "${path.root}/scripts/fedora/update_dnf.sh",
              "${path.root}/scripts/fedora/build-tools_fedora.sh",
              "${path.root}/scripts/fedora/install-supporting-packages_fedora.sh",
              "${path.root}/scripts/_common/motd.sh",
              "${path.root}/scripts/_common/sshd.sh",
              "${path.root}/scripts/_common/virtualbox.sh",
              "${path.root}/scripts/_common/vmware_fedora.sh",
              "${path.root}/scripts/_common/parallels-rhel.sh",
              "${path.root}/scripts/_common/vagrant.sh",
              "${path.root}/scripts/fedora/real-tmp_fedora.sh",
              "${path.root}/scripts/fedora/cleanup_dnf.sh",
              "${path.root}/scripts/_common/minimize.sh"
              ] : (
              "${var.os_name}-${substr(var.os_version, 0, 1)}" == "amazonlinux-2" ||
              "${var.os_name}-${substr(var.os_version, 0, 1)}" == "centos-7" ||
              "${var.os_name}-${substr(var.os_version, 0, 1)}" == "oraclelinux-7" ||
              "${var.os_name}-${substr(var.os_version, 0, 1)}" == "rhel-7" ||
              "${var.os_name}-${substr(var.os_version, 0, 1)}" == "scientificlinux-7" ||
              "${var.os_name}-${substr(var.os_version, 0, 1)}" == "springdalelinux-7" ? [
                "${path.root}/scripts/rhel/update_yum.sh",
                "${path.root}/scripts/_common/motd.sh",
                "${path.root}/scripts/_common/sshd.sh",
                "${path.root}/scripts/rhel/networking_rhel7.sh",
                "${path.root}/scripts/_common/vagrant.sh",
                "${path.root}/scripts/_common/virtualbox.sh",
                "${path.root}/scripts/_common/vmware_rhel.sh",
                "${path.root}/scripts/_common/parallels-rhel.sh",
                "${path.root}/scripts/rhel/cleanup_yum.sh",
                "${path.root}/scripts/_common/minimize.sh"
                ] : [
                "${path.root}/scripts/rhel/update_dnf.sh",
                "${path.root}/scripts/_common/motd.sh",
                "${path.root}/scripts/_common/sshd.sh",
                "${path.root}/scripts/_common/vagrant.sh",
                "${path.root}/scripts/_common/virtualbox.sh",
                "${path.root}/scripts/_common/vmware_rhel.sh",
                "${path.root}/scripts/_common/parallels-rhel.sh",
                "${path.root}/scripts/rhel/cleanup_dnf.sh",
                "${path.root}/scripts/_common/minimize.sh"
              ]
            )
          )
        )
      )
    )
  )
  source_names = [for source in var.sources_enabled : trimprefix(source, "source.")]
}

# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = var.sources_enabled

  # Linux Shell scipts
  provisioner "shell" {
    environment_vars = var.os_name == "freebsd" ? [
      "HOME_DIR=/home/vagrant",
      "http_proxy=${var.http_proxy}",
      "https_proxy=${var.https_proxy}",
      "no_proxy=${var.no_proxy}",
      "pkg_branch=quarterly"
      ] : (
      var.os_name == "solaris" ? [] : [
        "HOME_DIR=/home/vagrant",
        "http_proxy=${var.http_proxy}",
        "https_proxy=${var.https_proxy}",
        "no_proxy=${var.no_proxy}"
      ]
    )
    execute_command = var.os_name == "freebsd" ? "echo 'vagrant' | {{.Vars}} su -m root -c 'sh -eux {{.Path}}'" : (
      var.os_name == "solaris" ? "echo 'vagrant'|sudo -S bash {{.Path}}" : "echo 'vagrant' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    )
    expect_disconnect = true
    scripts           = local.scripts
    except            = var.is_windows ? local.source_names : null
  }

  # Windows Updates and scripts
  provisioner "powershell" {
    elevated_password = "vagrant"
    elevated_user     = "vagrant"
    scripts           = local.scripts
    except            = var.is_windows ? null : local.source_names
  }
  provisioner "windows-restart" {
    except = var.is_windows ? null : local.source_names
  }
  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    except          = var.is_windows ? null : local.source_names
  }
  provisioner "chef-solo" {
    chef_license = "accept-no-persist"
    version      = "17"
    cookbook_paths = [
      "${path.root}/cookbooks"
    ]
    guest_os_type = "windows"
    run_list = [
      "packer::disable_uac",
      "packer::configure_power",
      "packer::disable_screensaver",
      "packer::features",
      "packer::enable_file_sharing",
      "packer::ui_tweaks"
    ]
    except = var.is_windows ? null : local.source_names
  }
  provisioner "windows-restart" {
    except = var.is_windows ? null : local.source_names
  }
  provisioner "chef-solo" {
    chef_license = "accept-no-persist"
    version      = "17"
    cookbook_paths = [
      "${path.root}/cookbooks"
    ]
    guest_os_type = "windows"
    run_list = [
      "packer::cleanup",
      "packer::defrag"
    ]
    except = var.is_windows ? null : local.source_names
  }
  provisioner "powershell" {
    elevated_password = "vagrant"
    elevated_user     = "vagrant"
    scripts = [
      "${path.root}/scripts/windows/cleanup.ps1",
      "${path.root}/scripts/windows/optimize.ps1"
    ]
    except = var.is_windows ? null : local.source_names
  }

  # Convert machines to vagrant boxes
  post-processor "vagrant" {
    compression_level    = 9
    keep_input_artifact  = var.is_windows
    output               = "${path.root}/../builds/${var.os_name}-${var.os_version}-${var.os_arch}.{{ .Provider }}.box"
    vagrantfile_template = var.is_windows ? (var.hyperv_generation == 1 ? "${path.root}/vagrantfile-windows.template" : "${path.root}/vagrantfile-windows-gen2.template") : null
  }
}
