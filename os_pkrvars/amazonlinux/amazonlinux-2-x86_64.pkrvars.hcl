os_name            = "amazonlinux"
os_version         = "2"
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
    "${local.memory}",
    "--cpus", "2",
    "--nat-localhostreachable1",
    "on",
  ]
]
