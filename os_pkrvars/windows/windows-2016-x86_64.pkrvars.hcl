os_name    = "windows"
os_version = "2016"
os_arch    = "x86_64"
is_windows = true
# Download url's found at https://www.microsoft.com/en-us/evalcenter/download-windows-server-2016
iso_url                 = "https://software-static.download.prss.microsoft.com/pr/download/Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO"
iso_checksum            = "1ce702a578a3cb1ac3d14873980838590f06d5b7101c5daaccbac9d73f1fb50f"
parallels_guest_os_type = "win-2016"
vbox_guest_os_type      = "Windows2016_64"
vmware_guest_os_type    = "windows9srv-64"
utm_vm_icon             = "windows"
default_boot_wait       = "1s"
boot_command            = ["<esc><wait><up>"]
