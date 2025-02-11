os_name                 = "almalinux"
os_version              = "8.10"
os_arch                 = "aarch64"
iso_url                 = "https://repo.almalinux.org/almalinux/8/isos/aarch64/AlmaLinux-8.10-aarch64-minimal.iso"
iso_checksum            = "file:https://repo.almalinux.org/almalinux/8/isos/aarch64/CHECKSUM"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "Oracle_arm64"
vmware_guest_os_type    = "arm-rhel9-64"
boot_command            = ["<wait><up><wait>e<wait><down><wait><down><wait><end><wait> inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/8ks.cfg inst.repo=https://repo.almalinux.org/almalinux/8/BaseOS/aarch64/os/ <wait><leftCtrlOn><wait>x<wait><leftCtrlOff>"]
