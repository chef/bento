os_name                 = "rhel"
os_version              = "8.7"
os_arch                 = "aarch64"
iso_url                 = "https://www.redhat.com/en/technologies/linux-platforms/enterprise-linux"
iso_checksum            = "1b8004961150b60f6c5ec3f25139d3217eee55707cf9fa19e826919fc58e328b"
parallels_guest_os_type = "rhel"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/8ks.cfg<enter><wait>"]
