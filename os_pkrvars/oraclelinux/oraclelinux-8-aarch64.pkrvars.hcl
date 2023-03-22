os_name                 = "oraclelinux"
os_version              = "8.7"
os_arch                 = "aarch64"
iso_url                 = "https://yum.oracle.com/ISOS/OracleLinux/OL8/u7/aarch64/OracleLinux-R8-U7-aarch64-dvd.iso"
iso_checksum            = "420000aa561e833d8dc9576815d068fb5b15fd9fb826a0d9c127782004683741"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "arm-centos-64"
boot_command            = ["<wait><up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/8ks.cfg<enter><wait>"]
