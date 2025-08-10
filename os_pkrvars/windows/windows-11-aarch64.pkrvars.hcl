<<<<<<< HEAD
os_name                 = "windows"
os_version              = "11"
os_arch                 = "aarch64"
is_windows              = true
iso_url                 = "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26100.1.240331-1435.ge_release_CLIENTENTERPRISEEVAL_OEMRET_A64FRE_en-us.iso"
iso_checksum            = "DAD633276073F14F3E0373EF7E787569E216D54942CE522B39451C8F2D38AD43"
=======
os_name           = "windows"
os_version        = "11"
os_arch           = "aarch64"
is_windows        = true
hyperv_generation = 2
# Download url's found at https://www.microsoft.com/en-us/evalcenter/download-windows-11-enterprise
iso_url                 = "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26100.1.240331-1435.ge_release_CLIENTENTERPRISEEVAL_OEMRET_A64FRE_en-us.iso"
iso_checksum            = "DAD633276073F14F3E0373EF7E787569E216D54942CE522B39451C8F2D38AD43"
sources_enabled         = ["source.parallels-iso.vm", "source.qemu.vm", "source.vmware-iso.vm"]
>>>>>>> origin/main
parallels_guest_os_type = "win-11"
vbox_guest_os_type      = "Other_arm64"
vmware_guest_os_type    = "arm-windows11-64"
vmware_firmware         = "efi-secure"
parallels_boot_wait     = "180s"
boot_command            = ["<up><wait><down><down><enter><wait><up>", ]
