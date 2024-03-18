os_name            = "amazonlinux"
os_version         = "2023"
os_arch            = "x86_64"
parallels_guest_os_type = "fedora-core"
vbox_guest_os_type      = "Fedora_64"
vmware_guest_os_type    = "fedora-64"
sources_enabled = [
  "source.virtualbox-ovf.amazonlinux"
]
#vboxmanage = [
#  [
#    "modifyvm",
#    "{{ .Name }}",
#    "--memory",
#    "2048",
#    "--cpus",
#    "2",
#    "--audio",
#    "none",
#    "--nat-localhostreachable1",
#    "on",
#  ]
#]
iso_url                 = "https://cdn.amazonlinux.com/al2023/os-images/2023.3.20240219.0/vmware/al2023-vmware_esx-2023.3.20240219.0-kernel-6.1-x86_64.xfs.gpt.ova"
iso_checksum            = "file:https://cdn.amazonlinux.com/al2023/os-images/2023.3.20240219.0/vmware/SHA256SUMS"
#boot_command            = ["<wait><up><wait><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/rhel/7ks.cfg<enter><wait>"]
