locals {
  alma_os_version = "8.10"
  alma_os_major_version = split(".", local.os_version)[0]
}
os_name                 = "almalinux"
os_version              = local.alma_os_version
os_arch                 = "aarch64"
iso_url                 = "https://repo.almalinux.org/almalinux/${local.alma_os_major_version}/isos/aarch64/AlmaLinux-${local.alma_os_version}-aarch64-minimal.iso"
iso_checksum            = "file:https://repo.almalinux.org/almalinux/${local.alma_os_major_version}/isos/aarch64/CHECKSUM"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "arm-centos-64"
boot_command            = ["<wait><up>e<wait><down><down><end><wait> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/${local.alma_os_major_version}ks.cfg <leftCtrlOn>x<leftCtrlOff>"]
