#!/bin/bash -eux

zypper -n up
zypper -n in cloud-init

systemctl enable cloud-init

# Create opensuse user
sed -i -e ':a;N;$!ba;s/users:\n - root/users:\n - default/g' /etc/cloud/cloud.cfg
# Disable root and password logins
sed -i -e ':a;N;$!ba;s/disable_root: false\n/disable_root: 1\nssh_pwauth: 0\n/g' /etc/cloud/cloud.cfg

sed -i -e \
  's/GRUB_CMDLINE_LINUX=\"\(.*\)/GRUB_CMDLINE_LINUX=\"console=ttyS0,115200n8 console=tty0 \1/g' \
  /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

cat >> /etc/cloud/cloud.cfg.d/01_opensuse_user.cfg << EOF
system_info:
  default_user:
    name: opensuse
    lock_passwd: true
    gecos: Cloud User
    groups: [wheel, adm, systemd-journal]
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
EOF

rm -rf /etc/udev/rules.d/70-persistent-net.rules

# Remove older kernel
if [ "$(rpm -qa | grep ^kernel-default | wc -l)" != "1"  ] ; then
  rpm -qa | grep ^kernel-default | head -n 1 | xargs -n 1 zypper -n rm
fi
