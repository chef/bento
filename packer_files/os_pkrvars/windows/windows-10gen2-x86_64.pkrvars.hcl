os_name                 = "windows"
os_version              = "10gen2"
os_arch                 = "x86_64"
is_windows              = true
iso_url                 = "https://software-download.microsoft.com/download/pr/19041.264.200511-0456.vb_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
iso_checksum            = "sha1:F57E034095E0423FEB575CA82855F73E39FFA713"
parallels_guest_os_type = "win-10"
vbox_guest_os_type      = "Windows10_64"
vmware_guest_os_type    = "windows9srv-64"
boot_command            = "aaaaaaa<wait><enter><wait><enter><wait><enter>"
boot_command_hyperv     = "aaaaaaa"
hyperv_generation       = 2
sources_enabled = [
  "source.hyperv-iso.vm",
  "source.qemu.vm"
]
