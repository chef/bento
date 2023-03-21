os_name                 = "solaris"
os_version              = "11.4"
os_arch                 = "x86_64"
iso_url                 = "./packer_cache/sol-11_4-ai-x86.iso"
iso_checksum            = "sha256:e3a29507e583acbc0b912f371c8f328fea7cb6257d587cbc0a651477a52b0a29"
parallels_guest_os_type = "solaris"
vbox_guest_os_type      = "Solaris11_64"
vmware_guest_os_type    = "solaris11-64"
boot_command            = ["<wait>e<wait><down><down><down><down><down><wait><end><wait><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><wait>false<wait><f10><wait><wait10><wait10><wait10><wait10><wait10><wait10><wait10><wait10><wait10><wait10><wait10><wait10><wait10><wait10><wait10><wait10><wait10><wait10>root<enter><wait><wait>solaris<enter><wait><wait><wait10>while (true); do sleep 5; test -f /a/etc/sudoers && grep -v \"vagrant\" \"/a/etc/sudoers\" 2> /dev/null<wait> && echo \"vagrant ALL=(ALL) NOPASSWD: ALL\" >> /a/etc/sudoers && break ; done &<enter><wait><enter>while (true); do grep \"You may wish to reboot\" \"/var/svc/log/application-auto-installer:default.log\" 2> /dev/null<wait> && reboot; sleep 10; done &<enter><wait>sleep 5; curl http://{{ .HTTPIP }}:{{ .HTTPPort }}/solaris/default.xml -o default.xml;<wait>curl http://{{ .HTTPIP }}:{{ .HTTPPort }}/solaris/profile.xml -o profile.xml;<wait>cp default.xml /system/volatile/ai.xml;<wait>mkdir /system/volatile/profile;<wait>cp profile.xml /system/volatile/profile/profile.xml;<wait>svcadm enable svc:/application/auto-installer:default;<wait><enter><wait10><wait><wait><enter><wait>tail -f /var/svc/log/application-auto-installer\\:default.log<enter><wait>"]
