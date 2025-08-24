locals {
  common_scripts = [
    "${path.root}/scripts/_common/motd.sh",
    "${path.root}/scripts/_common/vagrant.sh",
    "${path.root}/scripts/_common/sshd.sh",
    "${path.root}/scripts/_common/guest_tools_virtualbox.sh",
    "${path.root}/scripts/_common/guest_tools_vmware.sh",
    "${path.root}/scripts/_common/guest_tools_parallels.sh",
    "${path.root}/scripts/_common/guest_tools_qemu.sh",
  ]
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
        "${path.root}/scripts/macos/system-update-complete.sh",
        "${path.root}/scripts/macos/disable_auto_update.sh"
        ] : (
        var.os_name == "solaris" ? [
          "${path.root}/scripts/solaris/update_solaris.sh",
          "${path.root}/scripts/solaris/vmtools_solaris.sh",
          "${path.root}/scripts/solaris/minimize_solaris.sh"
          ] : (
          var.os_name == "freebsd" ? [
            "${path.root}/scripts/freebsd/postinstall_freebsd.sh",
            "${path.root}/scripts/freebsd/sudoers_freebsd.sh",
            "${path.root}/scripts/freebsd/cleanup_freebsd.sh"
            ] : (
            var.os_name == "opensuse-leap" ||
            var.os_name == "sles" ? [
              "${path.root}/scripts/suse/unsupported-modules_suse.sh",
              "${path.root}/scripts/suse/vagrant_group_suse.sh",
              "${path.root}/scripts/suse/sudoers_suse.sh",
              "${path.root}/scripts/suse/zypper-locks_suse.sh",
              "${path.root}/scripts/suse/remove-dvd-source_suse.sh",
              "${path.root}/scripts/suse/cleanup_suse.sh"
              ] : (
              var.os_name == "ubuntu" ||
              var.os_name == "debian" ? [
                "${path.root}/scripts/${var.os_name}/networking_${var.os_name}.sh",
                "${path.root}/scripts/${var.os_name}/sudoers_${var.os_name}.sh",
                "${path.root}/scripts/${var.os_name}/systemd_${var.os_name}.sh",
                "${path.root}/scripts/${var.os_name}/hyperv_${var.os_name}.sh",
                "${path.root}/scripts/${var.os_name}/cleanup_${var.os_name}.sh",
                "${path.root}/scripts/_common/parallels_post_cleanup_debian_ubuntu.sh"
                ] : (
                var.os_name == "fedora" ? [
                  "${path.root}/scripts/fedora/networking_fedora.sh",
                  "${path.root}/scripts/fedora/install-supporting-packages_fedora.sh",
                  "${path.root}/scripts/fedora/real-tmp_fedora.sh",
                  "${path.root}/scripts/fedora/cleanup_dnf.sh",
                  ] : [
                  "${path.root}/scripts/rhel/cleanup_dnf.sh"
                ]
              )
            )
          )
        )
      )
    )
  ) : var.scripts
  nix_environment_vars = var.os_name == "freebsd" ? [
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
  nix_execute_command = var.os_name == "freebsd" ? "echo 'vagrant' | {{.Vars}} su -m root -c 'sh -eux {{.Path}}'" : (
    var.os_name == "solaris" ? "echo 'vagrant'|sudo -S bash {{.Path}}" : "echo 'vagrant' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
  )
  elevated_user     = "vagrant"
  elevated_password = "vagrant"
  source_names      = [for source in var.sources_enabled : trimprefix(source, "source.")]
}

# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = var.sources_enabled

  # Linux Shell scripts
  # Install updates and reboot
  provisioner "shell" {
    environment_vars  = local.nix_environment_vars
    execute_command   = local.nix_execute_command
    expect_disconnect = true
    pause_before      = "10s"
    scripts           = ["${path.root}/scripts/_common/update_packages.sh", ]
    valid_exit_codes  = [0, 143]
    except            = var.is_windows ? local.source_names : null
  }
  provisioner "shell" {
    inline = [
      "echo 'After reboot'"
    ]
    pause_after = "10s"
    except      = var.is_windows ? local.source_names : null
  }
  # Install build tools and reboot
  provisioner "shell" {
    environment_vars  = local.nix_environment_vars
    execute_command   = local.nix_execute_command
    expect_disconnect = true
    pause_before      = "10s"
    scripts           = ["${path.root}/scripts/_common/build_tools.sh", ]
    except            = var.is_windows ? local.source_names : null
  }
  provisioner "shell" {
    inline = [
      "echo 'After reboot'"
    ]
    pause_after = "10s"
    except      = var.is_windows ? local.source_names : null
  }
  # Run common scripts and guest tools installation
  provisioner "shell" {
    environment_vars  = local.nix_environment_vars
    execute_command   = local.nix_execute_command
    expect_disconnect = true
    pause_before      = "10s"
    scripts           = local.common_scripts
    except            = var.is_windows ? local.source_names : null
  }
  provisioner "shell" {
    inline = [
      "echo 'After reboot'"
    ]
    pause_after = "10s"
    except      = var.is_windows ? local.source_names : null
  }
  # Run OS specific scripts
  provisioner "shell" {
    environment_vars  = local.nix_environment_vars
    execute_command   = local.nix_execute_command
    expect_disconnect = true
    pause_before      = "10s"
    scripts           = local.scripts
    except            = var.is_windows ? local.source_names : null
  }
  # Run minimize script
  provisioner "shell" {
    environment_vars  = local.nix_environment_vars
    execute_command   = local.nix_execute_command
    expect_disconnect = true
    pause_after       = "10s"
    scripts           = ["${path.root}/scripts/_common/minimize.sh", ]
    except            = var.is_windows ? local.source_names : null
  }

  # Windows Updates and scripts
  provisioner "powershell" {
    elevated_password = local.elevated_password
    elevated_user     = local.elevated_user
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
    elevated_password = local.elevated_password
    elevated_user     = local.elevated_user
    scripts           = local.scripts
    except            = var.is_windows ? null : local.source_names
  }
  provisioner "windows-restart" {
    restart_timeout = "30m"
    except          = var.is_windows ? null : local.source_names
  }
  provisioner "powershell" {
    elevated_password = local.elevated_password
    elevated_user     = local.elevated_user
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
    except = ["utm-iso.vm"]
  }
  post-processor "utm-vagrant" {
    compression_level = 9
    output            = "${path.root}/../builds/${var.os_name}-${var.os_version}-${var.os_arch}.{{ .Provider }}.box"
    vagrantfile_template = var.is_windows ? "${path.root}/vagrantfile-windows-utm.template" : (
      var.os_name == "freebsd" ? "${path.root}/vagrantfile-freebsd-utm.template" : "${path.root}/vagrantfile-utm.template"
    )
    architecture = "${var.os_arch == "x86_64" ? "amd64" : var.os_arch == "aarch64" ? "arm64" : var.os_arch}"
    only         = ["utm-iso.vm"]
  }
}
