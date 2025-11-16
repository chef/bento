os_name           = "windows"
os_version        = "11"
os_arch           = "aarch64"
is_windows        = true
hyperv_generation = 2
# Download url's found at https://www.microsoft.com/en-us/evalcenter/download-windows-11-enterprise
iso_url                 = "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26200.6584.250915-1905.25h2_ge_release_svc_refresh_CLIENT_CONSUMER_a64fre_en-us.iso"
iso_checksum            = "32cde0071ed8086b29bb6c8c3bf17ba9e3cdf43200537434a811a9b6cc2711a1"
parallels_guest_os_type = "win-11"
vbox_guest_os_type      = "Windows11_arm64"
vmware_guest_os_type    = "arm-windows11-64"
utm_vm_icon             = "windows-11"
parallels_boot_wait     = "180s"
vbox_boot_wait          = "5s"
default_boot_wait       = "1s"
boot_command            = ["<enter><wait><up>"]
