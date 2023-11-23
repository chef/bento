os_name            = "amazonlinux"
os_version         = "2023"
os_arch            = "x86_64"
vbox_guest_os_type = "RedHat_64"
sources_enabled = [
  "source.virtualbox-ovf.amazonlinux"
]
vboxmanage = [
  [
    "modifyvm",
    "{{ .Name }}",
    "--memory",
    "2048",
    "--cpus",
    "2",
    "--audio",
    "none",
    "--nat-localhostreachable1",
    "on",
  ]
]
