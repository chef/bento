os_name    = "windows"
os_version = "2025"
os_arch    = "x86_64"
is_windows = true
# Download url's found at https://www.microsoft.com/en-us/evalcenter/download-windows-server-2025
iso_url                 = "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26100.1742.240906-0331.ge_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso"
iso_checksum            = "d0ef4502e350e3c6c53c15b1b3020d38a5ded011bf04998e950720ac8579b23d"
parallels_guest_os_type = "win-2022"
vbox_guest_os_type      = "Windows2022_64"
vmware_guest_os_type    = "windows2022srvNext-64"
utm_vm_icon             = "windows"
parallels_boot_wait     = "180s"
vbox_boot_wait          = "5s"
default_boot_wait       = "1s"
boot_command            = ["<enter><wait><up>"]
