os_name    = "windows"
os_version = "11"
os_arch    = "x86_64"
is_windows = true

# Download url's found at https://www.microsoft.com/en-us/evalcenter/download-windows-11-enterprise
iso_url      = "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26200.6584.250915-1905.25h2_ge_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
iso_checksum = "a61adeab895ef5a4db436e0a7011c92a2ff17bb0357f58b13bbc4062e535e7b9"

cpus      = 4
memory    = 6144
disk_size = 65536
headless  = true

qemu_binary           = "qemu-system-x86_64"
qemu_machine_type     = "q35"
qemu_cpu_model        = "host"
qemu_disk_interface   = "ide"
qemu_net_device       = "virtio-net-pci"
qemu_display          = "none"
qemu_use_pflash       = true

qemu_disk_compression   = true
qemu_disk_discard       = "unmap"
qemu_disk_detect_zeroes = "unmap"
qemu_efi_drop_efivars   = true

parallels_guest_os_type = "win-11"
vbox_guest_os_type      = "Windows11_64"
vmware_guest_os_type    = "windows11-64"
utm_vm_icon             = "windows-11"

default_boot_wait = "2s"
qemu_boot_wait    = "2s"
vbox_boot_wait    = "2s"
winrm_username    = "Administrator"
winrm_password    = "vagrant"
winrm_use_ntlm    = true
winrm_insecure    = true
winrm_use_ssl     = false
winrm_timeout     = "2h"
boot_command      = ["<spacebar><wait1s><spacebar><wait1s><spacebar><wait1s><spacebar><wait1s><spacebar><wait1s><spacebar><wait1s><spacebar><wait1s><spacebar>"]
