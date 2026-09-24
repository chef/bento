locals {
  # helper locals
  build_dir = abspath("${path.root}/../builds/")
  host_os   = var.host_os != null && var.host_os != "" ? var.host_os : (
    fileexists("/System/Library/CoreServices/SystemVersion.plist") ? "darwin" : (
      fileexists("/etc/os-release") ? "linux" : "windows"
    )
  )
  host_arch_raw = var.host_arch != null && var.host_arch != "" ? var.host_arch : (
    fileexists("/opt/homebrew/bin/brew") || fileexists("/lib/ld-linux-aarch64.so.1") || fileexists("/usr/lib/aarch64-linux-gnu") ? "arm64" : (
      fileexists("/usr/local/bin/brew") || fileexists("/lib64/ld-linux-x86-64.so.2") || fileexists("/usr/lib/x86_64-linux-gnu") ? "amd64" : (
        var.os_arch == "aarch64" ? "arm64" : "amd64"
      )
    )
  )
  host_arch = local.host_arch_raw == "arm64" ? "aarch64" : (local.host_arch_raw == "amd64" ? "x86_64" : local.host_arch_raw)

  # Source block provider specific
  # hyperv-iso
  hyperv_enable_dynamic_memory = var.hyperv_enable_dynamic_memory == null ? (
    var.hyperv_generation == 2 && var.is_windows ? true : false
  ) : var.hyperv_enable_dynamic_memory
  hyperv_enable_secure_boot = var.hyperv_enable_secure_boot == null ? (
    var.hyperv_generation == 2 && var.is_windows ? true : false
  ) : var.hyperv_enable_secure_boot

  # parallels-ipsw
  parallels_ipsw_target_path = var.parallels_ipsw_target_path == "build_dir_iso" && var.parallels_ipsw_url != null ? "${path.root}/../builds/iso/${var.os_name}-${var.os_version}-${var.os_arch}-${substr(sha256(var.parallels_ipsw_url), 0, 8)}.ipsw" : var.parallels_ipsw_target_path

  # parallels-iso
  parallels_tools_flavor = var.parallels_tools_flavor == null ? (
    var.is_windows ? (
      var.os_arch == "x86_64" ? "win" : "win-arm"
      ) : (
      var.os_name == "macos" ? (
        var.os_arch == "x86_64" ? "mac" : "mac-arm"
      ) :
      var.os_arch == "x86_64" ? "lin" : "lin-arm"
    )
  ) : var.parallels_tools_flavor
  parallels_tools_mode = var.parallels_tools_mode == null ? (
    var.is_windows ? "attach" : "upload"
  ) : var.parallels_tools_mode
  parallels_prlctl = var.parallels_prlctl == null ? (
    var.is_windows ? [
      ["set", "{{ .Name }}", "--efi-boot", "on"],
      ["set", "{{ .Name }}", "--efi-secure-boot", "off"],
      ] : (
      var.os_name == "freebsd" && var.os_arch == "x86_64" ? [
        ["set", "{{ .Name }}", "--bios-type", "efi64"],
        ["set", "{{ .Name }}", "--efi-boot", "on"],
        ["set", "{{ .Name }}", "--efi-secure-boot", "off"],
        ] : [
        ["set", "{{ .Name }}", "--3d-accelerate", "off"],
        ["set", "{{ .Name }}", "--videosize", "16"]
      ]
    )
  ) : var.parallels_prlctl

  # qemu
  qemu_accelerator = var.qemu_accelerator == null ? (
    local.host_os == "darwin" ? "hvf" : (
      local.host_os == "windows" ? "whpx" : "kvm"
    )
  ) : var.qemu_accelerator
  qemu_binary = var.qemu_binary == null ? "qemu-system-${var.os_arch}" : var.qemu_binary
  qemu_display = var.qemu_display == null ? (
    var.headless || local.host_os == "linux" ? "none" : (
      local.host_os == "darwin" ? "cocoa" : "none"
    )
  ) : var.qemu_display
  qemu_efi_boot = var.qemu_efi_boot == null ? true : var.qemu_efi_boot
  qemu_efi_firmware_code = local.qemu_efi_boot ? (
    var.qemu_efi_firmware_code != null && var.qemu_efi_firmware_code != "" ? var.qemu_efi_firmware_code : (
      var.os_arch == "aarch64" ? (
        fileexists("/opt/homebrew/share/qemu/edk2-aarch64-code.fd") ? "/opt/homebrew/share/qemu/edk2-aarch64-code.fd" : (
          fileexists("/usr/share/AAVMF/AAVMF_CODE.fd") ? "/usr/share/AAVMF/AAVMF_CODE.fd" : (
            fileexists("/usr/share/AAVMF/AAVMF32_CODE.fd") ? "/usr/share/AAVMF/AAVMF32_CODE.fd" : (
              fileexists("/usr/share/qemu/edk2-aarch64-code.fd") ? "/usr/share/qemu/edk2-aarch64-code.fd" : (
                fileexists("/usr/share/edk2/aarch64/QEMU_EFI-pflash.raw") ? "/usr/share/edk2/aarch64/QEMU_EFI-pflash.raw" : (
                  fileexists("/usr/share/edk2/aarch64/QEMU_EFI.fd") ? "/usr/share/edk2/aarch64/QEMU_EFI.fd" : (
                    fileexists("/usr/share/edk2-armvirt/aarch64/QEMU_EFI.fd") ? "/usr/share/edk2-armvirt/aarch64/QEMU_EFI.fd" : (
                      fileexists("/usr/local/share/qemu/edk2-aarch64-code.fd") ? "/usr/local/share/qemu/edk2-aarch64-code.fd" : (
                        fileexists("/opt/local/share/qemu/edk2-aarch64-code.fd") ? "/opt/local/share/qemu/edk2-aarch64-code.fd" : (
                          fileexists("C:/Program Files/qemu/share/edk2-aarch64-code.fd") ? "C:/Program Files/qemu/share/edk2-aarch64-code.fd" : (
                            local.host_os == "darwin" ? "/opt/homebrew/share/qemu/edk2-aarch64-code.fd" : (
                              local.host_os == "windows" ? "C:/Program Files/qemu/share/edk2-aarch64-code.fd" : "/usr/share/AAVMF/AAVMF_CODE.fd"
                            )
                          )
                        )
                      )
                    )
                  )
                )
              )
            )
          )
        )
      ) : (
        fileexists("/usr/share/OVMF/OVMF_CODE.fd") ? "/usr/share/OVMF/OVMF_CODE.fd" : (
          fileexists("/usr/share/OVMF/OVMF_CODE_4M.fd") ? "/usr/share/OVMF/OVMF_CODE_4M.fd" : (
            fileexists("/usr/share/ovmf/OVMF.fd") ? "/usr/share/ovmf/OVMF.fd" : (
              fileexists("/usr/share/edk2/ovmf/OVMF_CODE.fd") ? "/usr/share/edk2/ovmf/OVMF_CODE.fd" : (
                fileexists("/usr/share/edk2-ovmf/x64/OVMF_CODE.fd") ? "/usr/share/edk2-ovmf/x64/OVMF_CODE.fd" : (
                  fileexists("/opt/homebrew/share/qemu/edk2-x86_64-code.fd") ? "/opt/homebrew/share/qemu/edk2-x86_64-code.fd" : (
                    fileexists("/usr/local/share/qemu/edk2-x86_64-code.fd") ? "/usr/local/share/qemu/edk2-x86_64-code.fd" : (
                      fileexists("/opt/local/share/qemu/edk2-x86_64-code.fd") ? "/opt/local/share/qemu/edk2-x86_64-code.fd" : (
                        fileexists("/usr/share/qemu/edk2-x86_64-code.fd") ? "/usr/share/qemu/edk2-x86_64-code.fd" : (
                          fileexists("C:/Program Files/qemu/share/edk2-x86_64-code.fd") ? "C:/Program Files/qemu/share/edk2-x86_64-code.fd" : (
                            local.host_os == "darwin" ? "/opt/homebrew/share/qemu/edk2-x86_64-code.fd" : (
                              local.host_os == "windows" ? "C:/Program Files/qemu/share/edk2-x86_64-code.fd" : "/usr/share/OVMF/OVMF_CODE.fd"
                            )
                          )
                        )
                      )
                    )
                  )
                )
              )
            )
          )
        )
      )
    )
  ) : null
  qemu_efi_firmware_vars = local.qemu_efi_boot ? (
    var.qemu_efi_firmware_vars != null && var.qemu_efi_firmware_vars != "" ? var.qemu_efi_firmware_vars : (
      var.os_arch == "aarch64" ? (
        fileexists("/opt/homebrew/share/qemu/edk2-arm-vars.fd") ? "/opt/homebrew/share/qemu/edk2-arm-vars.fd" : (
          fileexists("/usr/share/AAVMF/AAVMF_VARS.fd") ? "/usr/share/AAVMF/AAVMF_VARS.fd" : (
            fileexists("/usr/share/qemu/edk2-arm-vars.fd") ? "/usr/share/qemu/edk2-arm-vars.fd" : (
              fileexists("/usr/share/edk2/aarch64/vars-template-pflash.raw") ? "/usr/share/edk2/aarch64/vars-template-pflash.raw" : (
                fileexists("/usr/share/edk2-armvirt/aarch64/QEMU_VARS.fd") ? "/usr/share/edk2-armvirt/aarch64/QEMU_VARS.fd" : (
                  fileexists("/usr/local/share/qemu/edk2-arm-vars.fd") ? "/usr/local/share/qemu/edk2-arm-vars.fd" : (
                    fileexists("/opt/local/share/qemu/edk2-arm-vars.fd") ? "/opt/local/share/qemu/edk2-arm-vars.fd" : (
                      fileexists("C:/Program Files/qemu/share/edk2-arm-vars.fd") ? "C:/Program Files/qemu/share/edk2-arm-vars.fd" : (
                        local.host_os == "darwin" ? "/opt/homebrew/share/qemu/edk2-arm-vars.fd" : (
                          local.host_os == "windows" ? "C:/Program Files/qemu/share/edk2-arm-vars.fd" : "/usr/share/AAVMF/AAVMF_VARS.fd"
                        )
                      )
                    )
                  )
                )
              )
            )
          )
        )
      ) : (
        fileexists("/usr/share/OVMF/OVMF_VARS.fd") ? "/usr/share/OVMF/OVMF_VARS.fd" : (
          fileexists("/usr/share/OVMF/OVMF_VARS_4M.fd") ? "/usr/share/OVMF/OVMF_VARS_4M.fd" : (
            fileexists("/usr/share/ovmf/OVMF_VARS.fd") ? "/usr/share/ovmf/OVMF_VARS.fd" : (
              fileexists("/usr/share/edk2/ovmf/OVMF_VARS.fd") ? "/usr/share/edk2/ovmf/OVMF_VARS.fd" : (
                fileexists("/usr/share/edk2-ovmf/x64/OVMF_VARS.fd") ? "/usr/share/edk2-ovmf/x64/OVMF_VARS.fd" : (
                  fileexists("/opt/homebrew/share/qemu/edk2-i386-vars.fd") ? "/opt/homebrew/share/qemu/edk2-i386-vars.fd" : (
                    fileexists("/usr/local/share/qemu/edk2-i386-vars.fd") ? "/usr/local/share/qemu/edk2-i386-vars.fd" : (
                      fileexists("/opt/local/share/qemu/edk2-i386-vars.fd") ? "/opt/local/share/qemu/edk2-i386-vars.fd" : (
                        fileexists("/usr/share/qemu/edk2-i386-vars.fd") ? "/usr/share/qemu/edk2-i386-vars.fd" : (
                          fileexists("C:/Program Files/qemu/share/edk2-i386-vars.fd") ? "C:/Program Files/qemu/share/edk2-i386-vars.fd" : (
                            local.host_os == "darwin" ? "/opt/homebrew/share/qemu/edk2-i386-vars.fd" : (
                              local.host_os == "windows" ? "C:/Program Files/qemu/share/edk2-i386-vars.fd" : "/usr/share/OVMF/OVMF_VARS.fd"
                            )
                          )
                        )
                      )
                    )
                  )
                )
              )
            )
          )
        )
      )
    )
  ) : null
  qemu_machine_type = var.qemu_machine_type == null ? (
    var.os_arch == "aarch64" ? "virt" : "q35"
  ) : var.qemu_machine_type
  win11_media_raw = var.win11_media_raw != null && var.win11_media_raw != "" ? var.win11_media_raw : (
    fileexists("${local.build_dir}/iso/win11_media.raw") ? "${local.build_dir}/iso/win11_media.raw" : (
      fileexists("${path.root}/../builds/iso/win11_media.raw") ? "${path.root}/../builds/iso/win11_media.raw" : ""
    )
  )
  win11_oem_iso_path = var.win11_oem_iso != null && var.win11_oem_iso != "" ? var.win11_oem_iso : (
    fileexists("${local.build_dir}/iso/bento_win11_arm64_unattend.iso") ? "${local.build_dir}/iso/bento_win11_arm64_unattend.iso" : (
      fileexists("${path.root}/../builds/iso/bento_win11_arm64_unattend.iso") ? "${path.root}/../builds/iso/bento_win11_arm64_unattend.iso" : ""
    )
  )
  qemu_win11_oem_args = local.win11_oem_iso_path != "" ? [
    ["-blockdev", "driver=file,node-name=oem_iso_f,filename=${local.win11_oem_iso_path},read-only=on"],
    ["-blockdev", "driver=raw,node-name=oem_iso_d,file=oem_iso_f,read-only=on"],
    ["-device", "usb-storage,bus=usb_xhci.0,drive=oem_iso_d,removable=on"]
  ] : []
  build_complete_dir = var.bento_build_complete_dir != null && var.bento_build_complete_dir != "" ? var.bento_build_complete_dir : "${local.build_dir}/build_complete"
  build_files_dir = var.bento_build_files_dir != null && var.bento_build_files_dir != "" ? var.bento_build_files_dir : "${local.build_dir}/build_files"

  qemuargs = var.qemuargs == null ? (
    var.is_windows ? (
      var.os_arch == "aarch64" && local.win11_media_raw != "" ? [
        ["-blockdev", "driver=file,node-name=win11media_f,filename=${local.win11_media_raw},read-only=on"],
        ["-blockdev", "driver=raw,node-name=win11media_d,file=win11media_f,read-only=on"],
        ["-device", "virtio-blk-pci,drive=win11media_d"],
        ["-device", "qemu-xhci"],
        ["-device", "usb-kbd"],
        ["-device", "usb-tablet"],
        ["-device", "ramfb"],
        ["-boot", "strict=off"],
        ["-serial", "file:${path.root}/../serial.log"],
      ] : (
        var.os_arch == "aarch64" ? (
          local.host_os == "windows" ? [
            ["-device", "qemu-xhci"],
            ["-device", "usb-kbd"],
            ["-device", "usb-tablet"],
            ["-device", "ramfb"],
            ["-boot", "strict=off"],
            ["-serial", "file:${path.root}/../serial.log"],
          ] : concat([
            ["-device", "pcie-root-port,id=pcie.1,chassis=1,slot=1"],
            ["-device", "nvme,serial=nvme0,drive=drive0,bus=pcie.1"],
            ["-device", "qemu-xhci,id=usb_xhci"],
          ], local.qemu_win11_oem_args, [
            ["-blockdev", "driver=file,node-name=win11_iso_f,filename=${replace(var.iso_url, "file://", "")},read-only=on"],
            ["-blockdev", "driver=raw,node-name=win11_iso_d,file=win11_iso_f,read-only=on"],
            ["-device", "usb-storage,bus=usb_xhci.0,drive=win11_iso_d,removable=on,logical_block_size=2048,physical_block_size=2048"],
            ["-device", "usb-kbd"],
            ["-device", "usb-tablet"],
            ["-device", "ramfb"],
            ["-boot", "strict=off"],
            ["-chardev", "socket,id=ser0,path=/tmp/windows-11-serial.sock,server=on,wait=off"],
            ["-serial", "chardev:ser0"],
          ])
        ) : (
          local.host_os == "windows" ? [
            ["-device", "qemu-xhci"],
            ["-device", "usb-kbd"],
            ["-device", "usb-tablet"],
            ["-vga", "std"],
            ["-boot", "strict=off"],
            ["-serial", "file:${path.root}/../serial.log"],
          ] : [
            ["-device", "qemu-xhci"],
            ["-device", "usb-kbd"],
            ["-device", "usb-tablet"],
            ["-vga", "std"],
            ["-boot", "strict=off"],
            ["-chardev", "socket,id=ser0,path=/tmp/windows-11-serial.sock,server=on,wait=off"],
            ["-serial", "chardev:ser0"],
          ]
        )
      )
    ) : [
      ["-device", "virtio-gpu-pci"],
      ["-device", "qemu-xhci"],
      ["-device", "virtio-tablet"],
      ["-device", "driver=virtio-keyboard-pci"],
      ["-device", "driver=virtio-mouse-pci"],
      ["-device", "driver=usb-kbd"],
      ["-device", "driver=usb-mouse"],
      ["-device", "virtio-serial"],
      ["-chardev", "socket,name=org.qemu.guest_agent.0,id=org.qemu.guest_agent,server=on,wait=off"],
      ["-device", "virtserialport,chardev=org.qemu.guest_agent,name=org.qemu.guest_agent.0"],
      ["-boot", "strict=off"],
    ]
  ) : var.qemuargs

  # utm-iso
  utm_boot_command = var.utm_boot_command == null ? (
    local.utm_disable_vnc ? null : local.default_boot_command
  ) : var.utm_boot_command
  utm_display_hardware_type = var.utm_display_hardware_type == null ? (
    var.os_arch == "aarch64" ? (
      var.is_windows ? "virtio-ramfb-gl" : "virtio-gpu-pci"
      ) : (
      var.is_windows ? "virtio-vga-gl" : "virtio-vga"
    )
  ) : var.utm_display_hardware_type
  utm_disable_vnc = var.utm_disable_vnc == null ? (
    var.is_windows ? true : false
  ) : var.utm_disable_vnc
  utm_guest_additions_mode = var.utm_guest_additions_mode == null ? (
    var.is_windows ? "attach" : "disable"
  ) : var.utm_guest_additions_mode
  utm_guest_additions_url = var.utm_guest_additions_url == null ? (
    var.is_windows ? "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.271-1/virtio-win.iso" : null
  ) : var.utm_guest_additions_url
  utm_guest_additions_sha256      = var.utm_guest_additions_sha256 == null ? "none" : var.utm_guest_additions_sha256
  utm_guest_additions_target_path = var.utm_guest_additions_target_path == null && local.utm_guest_additions_url != null ? "${path.root}/../builds/iso/${split(".", basename(local.utm_guest_additions_url))[0]}-${substr(sha256(local.utm_guest_additions_url), 0, 8)}.iso" : var.utm_guest_additions_target_path

  # virtualbox-iso
  vbox_chipset = var.vbox_chipset == null ? "ich9" : var.vbox_chipset
  vbox_gfx_controller = var.vbox_gfx_controller == null ? (
    var.is_windows ? "vboxsvga" : "vboxsvga"
  ) : var.vbox_gfx_controller
  vbox_gfx_vram_size = var.vbox_gfx_controller == null ? (
    var.is_windows ? 128 : 33
  ) : var.vbox_gfx_vram_size
  vbox_guest_additions_mode = var.vbox_guest_additions_mode == null ? (
    var.is_windows ? "attach" : "upload"
  ) : var.vbox_guest_additions_mode
  vbox_hard_drive_interface = var.vbox_hard_drive_interface == null ? (
    var.is_windows ? "sata" : "virtio"
  ) : var.vbox_hard_drive_interface
  vbox_iso_interface = var.vbox_iso_interface == null ? (
    var.is_windows ? "sata" : "virtio"
  ) : var.vbox_iso_interface
  vboxmanage = var.vboxmanage == null ? (
    var.is_windows ? (
      var.os_arch == "aarch64" ? [
        ["modifyvm", "{{.Name}}", "--chipset", "armv8virtual"],
        ["modifyvm", "{{.Name}}", "--audio-enabled", "off"],
        ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],
        ["modifyvm", "{{.Name}}", "--cableconnected1", "on"],
        ["modifyvm", "{{.Name}}", "--usb-xhci", "on"],
        ["modifyvm", "{{.Name}}", "--mouse", "usb"],
        ["modifyvm", "{{.Name}}", "--keyboard", "usb"],
        ["modifyvm", "{{.Name}}", "--nic-type1", "usbnet"],
        ] : [
        ["modifyvm", "{{.Name}}", "--audio-enabled", "off"],
        ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],
        ["modifyvm", "{{.Name}}", "--cableconnected1", "on"],
        ["modifyvm", "{{.Name}}", "--usb-xhci", "on"],
        ["modifyvm", "{{.Name}}", "--mouse", "usb"],
        ["modifyvm", "{{.Name}}", "--keyboard", "usb"],
        ["modifyvm", "{{.Name}}", "--uart1", "0x3f8", "4"],
        ["modifyvm", "{{.Name}}", "--uartmode1", local.host_os == "windows" ? "file" : "server", local.host_os == "windows" ? "${path.root}/../serial.log" : "/tmp/windows-11-serial.sock"],
      ]
      ) : (
      var.os_arch == "aarch64" ? [
        ["modifyvm", "{{.Name}}", "--chipset", "armv8virtual"],
        ["modifyvm", "{{.Name}}", "--audio-enabled", "off"],
        ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],
        ["modifyvm", "{{.Name}}", "--cableconnected1", "on"],
        ["modifyvm", "{{.Name}}", "--usb-xhci", "on"],
        ["modifyvm", "{{.Name}}", "--graphicscontroller", "qemuramfb"],
        ["modifyvm", "{{.Name}}", "--mouse", "usb"],
        ["modifyvm", "{{.Name}}", "--keyboard", "usb"],
        ["storagectl", "{{.Name}}", "--name", "IDE Controller", "--remove"],
        ] : [
        ["modifyvm", "{{.Name}}", "--audio-enabled", "off"],
        ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],
        ["modifyvm", "{{.Name}}", "--cableconnected1", "on"],
        ["modifyvm", "{{.Name}}", "--usb-xhci", "on"],
        ["modifyvm", "{{.Name}}", "--mouse", "usb"],
        ["modifyvm", "{{.Name}}", "--keyboard", "usb"],
        ["storagectl", "{{.Name}}", "--name", "IDE Controller", "--remove"],
      ]
    )
  ) : var.vboxmanage
  vbox_nic_type = var.vbox_nic_type == null ? (
    var.os_name == "freebsd" ? "82545EM" : null
  ) : var.vbox_nic_type

  # vmware-iso
  vmware_network_adapter_type = var.vmware_network_adapter_type == null ? (
    var.is_windows && var.os_arch == "aarch64" ? "vmxnet3" : "e1000e"
  ) : var.vmware_network_adapter_type
  vmware_tools_mode = var.vmware_tools_mode == null ? (
    var.is_windows ? (
      local.host_os == "darwin" && !fileexists("/Applications/VMware Fusion.app/Contents/Library/isoimages/arm64/windows.iso") ? "disable" : "attach"
    ) : "disable"
  ) : var.vmware_tools_mode
  vmware_tools_upload_flavor = local.vmware_tools_mode == "upload" && var.vmware_tools_source_path == null ? (
    var.vmware_tools_upload_flavor == null ? (
      var.is_windows ? "windows" : (
        var.os_name == "macos" ? "darwin" : "linux"
      )
    ) : var.vmware_tools_upload_flavor
  ) : null
  vmware_tools_upload_path = local.vmware_tools_mode == "upload" ? (
    var.vmware_tools_upload_path == null ? (
      var.is_windows ? "c:\\vmware-tools.iso" : "/tmp/vmware-tools.iso"
    ) : var.vmware_tools_upload_path
  ) : null
  vmware_tools_source_path = local.vmware_tools_mode == "disable" ? null : (
    var.vmware_tools_source_path == null ? (
      local.vmware_tools_mode == "attach" || local.vmware_tools_mode == "upload" ? (
        local.host_os == "darwin" ? (
          var.is_windows ? (
            var.os_arch == "aarch64" ? (
              fileexists("/Applications/VMware Fusion.app/Contents/Library/isoimages/arm64/windows.iso") ? "/Applications/VMware Fusion.app/Contents/Library/isoimages/arm64/windows.iso" : null
            ) : (
              fileexists("/Applications/VMware Fusion.app/Contents/Library/isoimages/x86_x64/windows.iso") ? "/Applications/VMware Fusion.app/Contents/Library/isoimages/x86_x64/windows.iso" : null
            )
          ) : null
          ) : (
          local.host_os == "windows" ? (
            var.is_windows ? "C:\\Program Files (x86)\\VMware\\VMware Workstation\\windows.iso" :
            "C:\\Program Files (x86)\\VMware\\VMware Workstation\\linux.iso"
            ) : (
            var.is_windows ? "/usr/lib/vmware/isoimages/windows.iso" :
            "/usr/lib/vmware/isoimages/linux.iso"
          )
        )
      ) : null # upload mode without source_path: let tools_upload_flavor handle it
    ) : var.vmware_tools_source_path
  )
  vmware_vmx_data = var.vmware_vmx_data == null ? (
    {
      "svga.autodetect"  = "TRUE"
      "usb_xhci.present" = "TRUE"
    }
  ) : var.vmware_vmx_data

  # Source block common
  cd_files = var.cd_files == null ? (
    var.is_windows ? (
      fileexists("${path.root}/cidata/virtio-win-guest-tools.exe") ? [
        "${path.root}/cidata/Balloon",
        "${path.root}/cidata/NetKVM",
        "${path.root}/cidata/pvpanic",
        "${path.root}/cidata/viofs",
        "${path.root}/cidata/viogpudo",
        "${path.root}/cidata/vioinput",
        "${path.root}/cidata/viomem",
        "${path.root}/cidata/viorng",
        "${path.root}/cidata/vioscsi",
        "${path.root}/cidata/vioserial",
        "${path.root}/cidata/viostor",
        "${path.root}/cidata/virtio-win-guest-tools.exe",
      ] : null
    ) : null
  ) : var.cd_files
  cd_label = var.cd_label == null ? (
    var.is_windows ? "OEMDRV" : "cidata"
  ) : var.cd_label
  cd_content = var.cd_content == null ? (
    var.is_windows ? {
      "Autounattend.xml" = templatefile(
        var.os_arch == "x86_64" ? (
          var.hyperv_generation == 2 ? "win_answer_files/${var.os_version}/hyperv-gen2/Autounattend.xml" : "win_answer_files/${var.os_version}/Autounattend.xml"
        ) : "win_answer_files/${var.os_version}/arm64/Autounattend.xml",
        { windows_product_key = var.windows_product_key }
      ),
      "SetupComplete.cmd" = file(
        var.os_arch == "x86_64" ? "win_answer_files/${var.os_version}/SetupComplete.cmd" : "win_answer_files/${var.os_version}/arm64/SetupComplete.cmd"
      )
    } : null
  ) : var.cd_content
  communicator = var.communicator == null ? (
    var.is_windows ? "winrm" : "ssh"
  ) : var.communicator
  default_boot_command = var.boot_command
  default_boot_wait = var.default_boot_wait == null ? (
    var.is_windows ? "60s" : "10s"
  ) : var.default_boot_wait
  disk_size = var.disk_size == null ? (
    var.is_windows ? 131072 : 65536
  ) : var.disk_size
  http_directory  = var.http_directory == null ? "${path.root}/http" : var.http_directory
  iso_target_path = var.iso_target_path == "build_dir_iso" && var.iso_url != null ? "${path.root}/../builds/iso/${var.os_name}-${var.os_version}-${var.os_arch}-${substr(sha256(var.iso_url), 0, 8)}.iso" : var.iso_target_path
  memory = var.memory == null ? (
    var.is_windows || var.os_name == "macos" || var.os_arch == "aarch64" ? 4096 : 3072
  ) : var.memory
  output_directory = var.output_directory == null ? "${local.build_files_dir}/packer-${var.os_name}-${var.os_version}-${var.os_arch}" : var.output_directory
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
  boot_command            = var.hyperv_boot_command == null ? local.default_boot_command : var.hyperv_boot_command
  boot_wait               = var.hyperv_boot_wait == null ? local.default_boot_wait : var.hyperv_boot_wait
  cd_content              = local.cd_content
  cd_files                = local.cd_files
  cd_label                = local.cd_label
  cpus                    = var.cpus
  communicator            = local.communicator
  disk_size               = local.disk_size
  floppy_files            = var.floppy_files
  headless                = var.headless
  http_directory          = local.http_directory
  iso_checksum            = var.iso_checksum
  iso_target_path         = local.iso_target_path
  iso_url                 = var.iso_url
  memory                  = local.memory
  output_directory        = "${local.output_directory}-hyperv"
  pause_before_connecting = var.pause_before_connecting
  shutdown_command        = local.shutdown_command
  shutdown_timeout        = var.shutdown_timeout
  ssh_password            = var.ssh_password
  ssh_port                = var.ssh_port
  ssh_read_write_timeout  = var.ssh_read_write_timeout
  ssh_timeout             = var.ssh_timeout
  ssh_username            = var.ssh_username
  winrm_password          = var.winrm_password
  winrm_timeout           = var.winrm_timeout
  winrm_username          = var.winrm_username
  winrm_use_ntlm          = var.winrm_use_ntlm
  winrm_insecure          = var.winrm_insecure
  winrm_use_ssl           = var.winrm_use_ssl
  vm_name                 = local.vm_name
}
source "parallels-ipsw" "vm" {
  # Parallels specific options
  host_interfaces     = var.parallels_host_interfaces
  ipsw_url            = var.parallels_ipsw_url
  ipsw_checksum       = var.parallels_ipsw_checksum
  ipsw_target_path    = local.parallels_ipsw_target_path
  prlctl              = local.parallels_prlctl
  prlctl_post         = var.parallels_prlctl_post
  prlctl_version_file = var.parallels_prlctl_version_file
  # Source block common options
  boot_command            = var.parallels-ipsw_boot_command == null ? local.default_boot_command : var.parallels_boot_command
  boot_wait               = var.parallels_boot_wait == null ? local.default_boot_wait : var.parallels_boot_wait
  cpus                    = var.cpus
  communicator            = local.communicator
  disk_size               = local.disk_size
  http_directory          = local.http_directory
  http_content            = var.http_content
  memory                  = local.memory
  output_directory        = "${local.output_directory}-parallels"
  pause_before_connecting = var.pause_before_connecting
  shutdown_command        = local.shutdown_command
  shutdown_timeout        = var.shutdown_timeout
  ssh_password            = var.ssh_password
  ssh_port                = var.ssh_port
  ssh_read_write_timeout  = var.ssh_read_write_timeout
  ssh_timeout             = var.ssh_timeout
  ssh_username            = var.ssh_username
  vm_name                 = local.vm_name
}
source "parallels-iso" "vm" {
  # Parallels specific options
  guest_os_type          = var.parallels_guest_os_type
  parallels_tools_flavor = local.parallels_tools_flavor
  parallels_tools_mode   = local.parallels_tools_mode
  prlctl                 = local.parallels_prlctl
  prlctl_version_file    = var.parallels_prlctl_version_file
  # Source block common options
  boot_command            = var.parallels-iso_boot_command == null ? local.default_boot_command : var.parallels_boot_command
  boot_wait               = var.parallels_boot_wait == null ? local.default_boot_wait : var.parallels_boot_wait
  cd_content              = local.cd_content
  cd_files                = local.cd_files
  cd_label                = local.cd_label
  cpus                    = var.cpus
  communicator            = local.communicator
  disk_size               = local.disk_size
  floppy_files            = var.floppy_files
  http_directory          = local.http_directory
  iso_checksum            = var.iso_checksum
  iso_target_path         = local.iso_target_path
  iso_url                 = var.iso_url
  memory                  = local.memory
  output_directory        = "${local.output_directory}-parallels"
  pause_before_connecting = var.pause_before_connecting
  shutdown_command        = local.shutdown_command
  shutdown_timeout        = var.shutdown_timeout
  ssh_password            = var.ssh_password
  ssh_port                = var.ssh_port
  ssh_read_write_timeout  = var.ssh_read_write_timeout
  ssh_timeout             = var.ssh_timeout
  ssh_username            = var.ssh_username
  winrm_password          = var.winrm_password
  winrm_timeout           = var.winrm_timeout
  winrm_username          = var.winrm_username
  winrm_use_ntlm          = var.winrm_use_ntlm
  winrm_insecure          = var.winrm_insecure
  winrm_use_ssl           = var.winrm_use_ssl
  vm_name                 = local.vm_name
}
source "qemu" "vm" {
  # QEMU specific options
  accelerator         = local.qemu_accelerator
  cpu_model           = var.qemu_cpu_model
  display             = local.qemu_display
  disk_cache          = var.qemu_disk_cache
  disk_compression    = var.qemu_disk_compression
  disk_detect_zeroes  = var.qemu_disk_detect_zeroes
  disk_discard        = var.qemu_disk_discard
  disk_image          = var.qemu_disk_image
  disk_interface      = var.qemu_disk_interface
  efi_boot            = local.qemu_efi_boot
  efi_firmware_code   = local.qemu_efi_firmware_code
  efi_firmware_vars   = local.qemu_efi_firmware_vars
  efi_drop_efivars    = var.qemu_efi_drop_efivars
  format              = var.qemu_format
  machine_type        = local.qemu_machine_type
  net_device          = var.qemu_net_device
  qemu_binary         = local.qemu_binary
  qemuargs            = local.qemuargs
  use_default_display = var.qemu_use_default_display
  use_pflash          = var.qemu_use_pflash
  vnc_bind_address    = var.qemu_vnc_bind_address
  vnc_port_min        = var.qemu_vnc_port_min
  vnc_port_max        = var.qemu_vnc_port_max
  vnc_password        = ""
  # Source block common options
  boot_command            = var.qemu_boot_command == null ? local.default_boot_command : var.qemu_boot_command
  boot_wait               = var.qemu_boot_wait == null ? local.default_boot_wait : var.qemu_boot_wait
  cd_content              = local.cd_content
  cd_files                = local.cd_files
  cd_label                = local.cd_label
  cpus                    = var.cpus
  communicator            = local.communicator
  disk_size               = local.disk_size
  floppy_files            = var.floppy_files
  headless                = var.headless
  http_directory          = local.http_directory
  iso_checksum            = var.iso_checksum
  iso_target_path         = local.iso_target_path
  iso_url                 = var.iso_url
  memory                  = local.memory
  output_directory        = "${local.output_directory}-qemu"
  pause_before_connecting = var.pause_before_connecting
  shutdown_command        = local.shutdown_command
  shutdown_timeout        = var.shutdown_timeout
  ssh_password            = var.ssh_password
  ssh_port                = var.ssh_port
  ssh_read_write_timeout  = var.ssh_read_write_timeout
  ssh_timeout             = var.ssh_timeout
  ssh_username            = var.ssh_username
  winrm_password          = var.winrm_password
  winrm_timeout           = var.winrm_timeout
  winrm_username          = var.winrm_username
  winrm_use_ntlm          = var.winrm_use_ntlm
  winrm_insecure          = var.winrm_insecure
  winrm_use_ssl           = var.winrm_use_ssl
  vm_name                 = local.vm_name
}
source "utm-iso" "vm" {
  # UTM specific options
  boot_nopause                = var.utm_boot_nopause
  disable_vnc                 = local.utm_disable_vnc
  display_hardware_type       = local.utm_display_hardware_type
  display_nopause             = var.utm_display_nopause
  export_nopause              = var.utm_export_nopause
  guest_additions_mode        = local.utm_guest_additions_mode
  guest_additions_path        = var.utm_guest_additions_path
  guest_additions_interface   = var.utm_guest_additions_interface
  guest_additions_url         = local.utm_guest_additions_url
  guest_additions_sha256      = local.utm_guest_additions_sha256
  guest_additions_target_path = local.utm_guest_additions_target_path
  hard_drive_interface        = var.utm_hard_drive_interface
  hypervisor                  = var.utm_hypervisor
  iso_interface               = var.utm_iso_interface
  uefi_boot                   = var.utm_uefi_boot
  vm_arch                     = var.os_arch
  vm_backend                  = var.utm_vm_backend
  vm_icon                     = var.utm_vm_icon
  # Source block common options
  boot_command            = local.utm_boot_command
  boot_wait               = var.utm_boot_wait == null ? local.default_boot_wait : var.utm_boot_wait
  cd_content              = local.cd_content
  cd_files                = local.cd_files
  cd_label                = local.cd_label
  cpus                    = var.cpus
  communicator            = local.communicator
  disk_size               = local.disk_size
  floppy_files            = var.floppy_files
  http_directory          = local.http_directory
  iso_checksum            = var.iso_checksum
  iso_target_path         = local.iso_target_path
  iso_url                 = var.iso_url
  memory                  = local.memory
  output_directory        = "${local.output_directory}-utm"
  pause_before_connecting = var.pause_before_connecting
  shutdown_command        = local.shutdown_command
  shutdown_timeout        = var.shutdown_timeout
  ssh_password            = var.ssh_password
  ssh_port                = var.ssh_port
  ssh_read_write_timeout  = var.ssh_read_write_timeout
  ssh_timeout             = var.ssh_timeout
  ssh_username            = var.ssh_username
  winrm_password          = var.winrm_password
  winrm_timeout           = var.winrm_timeout
  winrm_username          = var.winrm_username
  winrm_use_ntlm          = var.winrm_use_ntlm
  winrm_insecure          = var.winrm_insecure
  winrm_use_ssl           = var.winrm_use_ssl
  vm_name                 = local.vm_name
}
source "virtualbox-iso" "vm" {
  # Virtualbox specific options
  chipset                   = local.vbox_chipset
  firmware                  = var.vbox_firmware
  gfx_accelerate_3d         = var.vbox_gfx_accelerate_3d
  gfx_controller            = local.vbox_gfx_controller
  gfx_vram_size             = local.vbox_gfx_vram_size
  guest_additions_path      = var.vbox_guest_additions_path
  guest_additions_mode      = local.vbox_guest_additions_mode
  guest_additions_interface = var.vbox_guest_additions_interface
  guest_os_type             = var.vbox_guest_os_type
  hard_drive_interface      = local.vbox_hard_drive_interface
  iso_interface             = local.vbox_iso_interface
  nested_virt               = var.vbox_nested_virt
  nic_type                  = local.vbox_nic_type
  rtc_time_base             = var.vbox_rtc_time_base
  usb                       = var.vbox_usb
  vboxmanage                = local.vboxmanage
  virtualbox_version_file   = var.virtualbox_version_file
  # Source block common options
  boot_command            = var.vbox_boot_command == null ? local.default_boot_command : var.vbox_boot_command
  boot_wait               = var.vbox_boot_wait == null ? local.default_boot_wait : var.vbox_boot_wait
  cd_content              = local.cd_content
  cd_files                = local.cd_files
  cd_label                = local.cd_label
  cpus                    = var.cpus
  communicator            = local.communicator
  disk_size               = local.disk_size
  floppy_files            = var.floppy_files
  headless                = var.headless
  http_directory          = local.http_directory
  iso_checksum            = var.iso_checksum
  iso_target_path         = local.iso_target_path
  iso_url                 = var.iso_url
  memory                  = local.memory
  output_directory        = "${local.output_directory}-virtualbox"
  pause_before_connecting = var.pause_before_connecting
  shutdown_command        = local.shutdown_command
  shutdown_timeout        = var.shutdown_timeout
  ssh_password            = var.ssh_password
  ssh_port                = var.ssh_port
  ssh_read_write_timeout  = var.ssh_read_write_timeout
  ssh_timeout             = var.ssh_timeout
  ssh_username            = var.ssh_username
  winrm_password          = var.winrm_password
  winrm_timeout           = var.winrm_timeout
  winrm_username          = var.winrm_username
  winrm_use_ntlm          = var.winrm_use_ntlm
  winrm_insecure          = var.winrm_insecure
  winrm_use_ssl           = var.winrm_use_ssl
  vm_name                 = local.vm_name
}
source "virtualbox-ovf" "vm" {
  # Virtualbox specific options
  guest_additions_path    = var.vbox_guest_additions_path
  source_path             = var.vbox_source_path
  checksum                = var.vbox_checksum
  vboxmanage              = local.vboxmanage
  virtualbox_version_file = var.virtualbox_version_file
  # Source block common options
  communicator            = local.communicator
  headless                = var.headless
  output_directory        = "${local.output_directory}-virtualbox-ovf"
  pause_before_connecting = var.pause_before_connecting
  shutdown_command        = local.shutdown_command
  shutdown_timeout        = var.shutdown_timeout
  ssh_password            = var.ssh_password
  ssh_port                = var.ssh_port
  ssh_read_write_timeout  = var.ssh_read_write_timeout
  ssh_timeout             = var.ssh_timeout
  ssh_username            = var.ssh_username
  vm_name                 = local.vm_name
}
source "vmware-iso" "vm" {
  # VMware specific options
  cores                          = var.vmware_cores
  cdrom_adapter_type             = var.vmware_cdrom_adapter_type
  disk_adapter_type              = var.vmware_disk_adapter_type
  firmware                       = var.vmware_firmware
  guest_os_type                  = var.vmware_guest_os_type
  network                        = var.vmware_network
  network_adapter_type           = local.vmware_network_adapter_type
  tools_mode                     = var.vmware_tools_mode != null ? var.vmware_tools_mode : "disable"
  tools_source_path              = var.vmware_tools_source_path
  tools_upload_flavor            = local.vmware_tools_upload_flavor
  tools_upload_path              = local.vmware_tools_upload_path
  usb                            = var.vmware_usb
  version                        = var.vmware_version
  vmx_data                       = local.vmware_vmx_data
  vmx_remove_ethernet_interfaces = var.vmware_vmx_remove_ethernet_interfaces
  vnc_disable_password           = var.vmware_vnc_disable_password
  # Source block common options
  boot_command            = var.vmware_boot_command == null ? local.default_boot_command : var.vmware_boot_command
  boot_wait               = var.vmware_boot_wait == null ? local.default_boot_wait : var.vmware_boot_wait
  cd_content              = local.cd_content
  cd_files                = local.cd_files
  cd_label                = local.cd_label
  cpus                    = var.cpus
  communicator            = local.communicator
  disk_size               = local.disk_size
  floppy_files            = var.floppy_files
  headless                = var.headless
  http_directory          = local.http_directory
  iso_checksum            = var.iso_checksum
  iso_target_path         = abspath(local.iso_target_path)
  iso_url                 = var.iso_url
  memory                  = local.memory
  output_directory        = "${local.output_directory}-vmware"
  pause_before_connecting = var.pause_before_connecting
  shutdown_command        = local.shutdown_command
  shutdown_timeout        = var.shutdown_timeout
  ssh_password            = var.ssh_password
  ssh_port                = var.ssh_port
  ssh_read_write_timeout  = var.ssh_read_write_timeout
  ssh_timeout             = var.ssh_timeout
  ssh_username            = var.ssh_username
  winrm_password          = var.winrm_password
  winrm_timeout           = var.winrm_timeout
  winrm_username          = var.winrm_username
  winrm_use_ntlm          = var.winrm_use_ntlm
  winrm_insecure          = var.winrm_insecure
  winrm_use_ssl           = var.winrm_use_ssl
  vm_name                 = local.vm_name
}
