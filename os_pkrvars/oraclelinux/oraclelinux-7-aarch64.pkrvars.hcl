os_name                 = "oraclelinux"
os_version              = "7.9"
os_arch                 = "aarch64"
is_windows              = false
iso_url                 = "http://mirrors.dotsrc.org/oracle-linux/OL7/u9/aarch64/OracleLinux-R7-U9-Server-aarch64-dvd.iso"
iso_checksum            = "fd2c1b1e26858576534f6e6c4cf000a15cd81bec010dad5e827b204a14a1750e"
parallels_guest_os_type = "centos"
vbox_guest_os_type      = "RedHat_64"
vmware_guest_os_type    = "centos-64"
boot_command            = ["<up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/7ks.cfg<enter><wait>"]
boot_command_hyperv     = ["<wait5><up><wait5><tab> text ks=hd:fd0:/ks.cfg<enter><wait5><esc>"]
