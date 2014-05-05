#!/bin/sh -x

# Autohome
# ------------------------------
echo '==> Setting up auto_home'
echo '*       localhost:/export/home/&' >> /etc/auto_home

# Grub timeout
# ------------------------------
echo '==> Setting grub timeout'
sed -i 's/timeout 30/timeout 1/' /rpool/boot/grub/menu.lst

# Hostname
# ------------------------------
echo '==> Setting vagrant hostname'
echo vagrant-omnios > /etc/nodename
svcadm restart svc:/system/identity:node

# Setting hostname
# ------------------------------
echo '==> Setting vagrant hostname'
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

cat <<EOF >> /etc/ssh/sshd_config

LookupClientHostnames no
EOF

# Zeroing disk
# ------------------------------
echo '==> Zeroing disk'
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
