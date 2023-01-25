os_name                 = "centos-stream"
os_version              = "9"
os_arch                 = "x86_64"
iso_url                 = "https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-20230123.0-x86_64-boot.iso"
iso_checksum            = "file:https://mirror.stream.centos.org/9-stream/BaseOS/x86_64/iso/SHA256SUM"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/9ks.cfg<enter><wait>"]
boot_command_hyperv     = ["<wait5><up><wait5><tab> text ks=hd:fd0:/ks.cfg<enter><wait5><esc>"]
