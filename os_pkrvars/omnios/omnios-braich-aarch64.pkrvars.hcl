os_name           = "omnios"
os_version        = "braich"
os_arch           = "aarch64"
iso_url           = "https://downloads.omnios.org/media/braich/braich-151059.raw.zst"
iso_checksum      = "sha256:c6e8faed3d9b1a747a827fbef21101100f1fc148ef19e821ffbf1491f45230b5"
qemu_binary       = "qemu-system-aarch64"
qemu_machine_type = "virt"
qemu_cpu_model    = "cortex-a57"
qemu_disk_image   = true
utm_vm_icon       = "solaris"
default_boot_wait = "15s"
qemuargs = [
  ["-semihosting-config", "enable=on,target=native"],
  ["-bios", "u-boot.bin"]
]
ssh_username     = "vagrant"
ssh_password     = "vagrant"
ssh_port         = 22
ssh_timeout      = "30m"
shutdown_command = "sudo /sbin/init 5"
