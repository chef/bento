packer {
  required_version = ">= 1.7.0"
  required_plugins {
    hyperv = {
      version = ">= 1.0.3"
      source  = "github.com/hashicorp/hyperv"
    }
    parallels = {
      version = ">= 1.1.6"
      source  = "github.com/parallels/parallels"
    }
    qemu = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/qemu"
    }
    vagrant = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/vagrant"
    }
    virtualbox = {
      version = ">= 1.0.3"
      source  = "github.com/hashicorp/virtualbox"
    }
    vmware = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/vmware"
    }
    windows-update = {
      version = ">= 0.14.1"
      source  = "github.com/rgl/windows-update"
    }
  }
}

locals {
  scripts = var.scripts == null ? (
    var.is_windows ? [
      "${path.root}/scripts/windows/configure-power.ps1",
      "${path.root}/scripts/windows/disable-windows-uac.ps1",
      "${path.root}/scripts/windows/disable-system-restore.ps1",
      "${path.root}/scripts/windows/disable-screensaver.ps1",
      "${path.root}/scripts/windows/ui-tweaks.ps1",
      "${path.root}/scripts/windows/disable-windows-updates.ps1",
      "${path.root}/scripts/windows/disable-windows-defender.ps1",
      "${path.root}/scripts/windows/enable-remote-desktop.ps1",
      "${path.root}/scripts/windows/enable-file-sharing.ps1",
      "${path.root}/scripts/windows/eject-media.ps1"
      ] : (
      var.os_name == "macos" ? [
        "${path.root}/scripts/macos/system-default.sh",
        "${path.root}/scripts/macos/system-update.sh",
        "${path.root}/scripts/macos/system-update-complete.sh",
        "${path.root}/scripts/_common/motd.sh",
        "${path.root}/scripts/macos/vagrant.sh",
        "${path.root}/scripts/macos/parallels-tools.sh",
        "${path.root}/scripts/macos/vmware-tools.sh",
        "${path.root}/scripts/macos/disable_auto_update.sh",
        "${path.root}/scripts/macos/shrink.sh"
        ] : (
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
            var.os_name == "opensuse-leap" ||
            var.os_name == "sles" ? [
              "${path.root}/scripts/suse/repositories_suse.sh",
              "${path.root}/scripts/suse/update_suse.sh",
              "${path.root}/scripts/_common/motd.sh",
              "${path.root}/scripts/_common/sshd.sh",
              "${path.root}/scripts/_common/vagrant.sh",
              "${path.root}/scripts/suse/unsupported-modules_suse.sh",
              "${path.root}/scripts/_common/virtualbox.sh",
              "${path.root}/scripts/_common/vmware.sh",
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
                "${path.root}/scripts/_common/vmware.sh",
                "${path.root}/scripts/_common/parallels.sh",
                "${path.root}/scripts/${var.os_name}/hyperv_${var.os_name}.sh",
                "${path.root}/scripts/${var.os_name}/cleanup_${var.os_name}.sh",
                "${path.root}/scripts/_common/parallels_post_cleanup_debian_ubuntu.sh",
                "${path.root}/scripts/_common/minimize.sh"
                ] : (
                var.os_name == "fedora" ? [
                  "${path.root}/scripts/fedora/networking_fedora.sh",
                  "${path.root}/scripts/fedora/update_dnf.sh",
                  "${path.root}/scripts/_common/motd.sh",
                  "${path.root}/scripts/_common/sshd.sh",
                  "${path.root}/scripts/fedora/install-supporting-packages_fedora.sh",
                  "${path.root}/scripts/fedora/build-tools_fedora.sh",
                  "${path.root}/scripts/_common/virtualbox.sh",
                  "${path.root}/scripts/_common/vmware.sh",
                  "${path.root}/scripts/_common/parallels.sh",
                  "${path.root}/scripts/_common/vagrant.sh",
                  "${path.root}/scripts/fedora/real-tmp_fedora.sh",
                  "${path.root}/scripts/fedora/cleanup_dnf.sh",
                  "${path.root}/scripts/_common/minimize.sh"
                  ] : var.os_name == "alpine" ? [
                    "${path.root}/scripts/alpine/networking_alpine.sh",
                    "${path.root}/scripts/alpine/update_apk.sh",
                    "${path.root}/scripts/_common/motd.sh",
                    "${path.root}/scripts/_common/sshd.sh",
                    "${path.root}/scripts/alpine/install-supporting-packages_alpine.sh",
                    "${path.root}/scripts/alpine/build-tools_alpine.sh",
                    "${path.root}/scripts/_common/virtualbox.sh",
                    "${path.root}/scripts/_common/vmware.sh",
                    "${path.root}/scripts/_common/parallels.sh",
                    "${path.root}/scripts/_common/vagrant.sh",
                    "${path.root}/scripts/alpine/real-tmp_alpine.sh",
                    "${path.root}/scripts/alpine/cleanup_apk.sh",
                    "${path.root}/scripts/_common/minimize.sh"
                    ] : [
                      "${path.root}/scripts/rhel/update_dnf.sh",
                      "${path.root}/scripts/_common/motd.sh",
                      "${path.root}/scripts/_common/sshd.sh",
                      "${path.root}/scripts/_common/vagrant.sh",
                      "${path.root}/scripts/_common/virtualbox.sh",
                      "${path.root}/scripts/_common/vmware.sh",
                      "${path.root}/scripts/_common/parallels.sh",
                      "${path.root}/scripts/rhel/cleanup_dnf.sh",
                      "${path.root}/scripts/_common/minimize.sh"
                    ]
              )
            )
          )
        )
      )
    )
  ) : var.scripts
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
    scripts = [
      "${path.root}/scripts/windows/provision.ps1",
      "${path.root}/scripts/windows/remove-one-drive-and-teams.ps1",
      "${path.root}/scripts/windows/remove-apps.ps1",
      "${path.root}/scripts/windows/remove-capabilities.ps1",
      "${path.root}/scripts/windows/remove-features.ps1",
    ]
    except = var.is_windows ? null : local.source_names
  }
  provisioner "windows-restart" {
    restart_timeout = "30m"
    except          = var.is_windows ? null : local.source_names
  }
  provisioner "windows-update" {
    search_criteria = "IsInstalled=0 and IsHidden = 0"
    filters = [
      "exclude:$_.Title -like '*Preview*'",
      "exclude:$_.Title -like '*Cumulative Update for Microsoft server*'",
      "exclude:$_.Title -like '*Cumulative Update for Windows *'",
      "include:$true",
    ]
    except = var.is_windows ? null : local.source_names
  }
  provisioner "windows-restart" {
    restart_timeout = "30m"
    except          = var.is_windows ? null : local.source_names
  }
  provisioner "powershell" {
    elevated_password = "vagrant"
    elevated_user     = "vagrant"
    scripts           = local.scripts
    except            = var.is_windows ? null : local.source_names
  }
  provisioner "windows-restart" {
    restart_timeout = "30m"
    except          = var.is_windows ? null : local.source_names
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
    compression_level = 9
    output            = "${path.root}/../builds/${var.os_name}-${var.os_version}-${var.os_arch}.{{ .Provider }}.box"
    vagrantfile_template = var.is_windows ? "${path.root}/vagrantfile-windows.template" : (
      var.os_name == "freebsd" ? "${path.root}/vagrantfile-freebsd.template" : null
    )
  }
}
