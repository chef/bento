os_name                 = "windows"
os_version              = "11gen2"
os_arch                 = "x86_64"
is_windows              = true
iso_url                 = "https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/22000.318.211104-1236.co_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
iso_checksum            = "sha256:684BC16ADBD792EF2F7810158A3F387F23BF95E1AEE5F16270C5B7F56DB753B6"
parallels_guest_os_type = "win-11"
vbox_guest_os_type      = "Windows11_64"
vmware_guest_os_type    = "windows9srv-64"
hyperv_generation       = 2
boot_command_hyperv     = "aaaaaaa"
boot_command            = "aaaaaaa<wait><enter><wait><enter><wait><enter>"
sources_enabled = [
  "source.hyperv-iso.vm",
  "source.qemu.vm"
]
