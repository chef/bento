#!/bin/bash -eux

dracut -f

# output bootup to serial
sed -i -e \
  's/GRUB_CMDLINE_LINUX=\"\(.*\)/GRUB_CMDLINE_LINUX=\"console=ttyS0,115200n8 console=tty0 \1/g' \
  /etc/default/grub
# No timeout for grub menu
sed -i -e 's/^GRUB_TIMEOUT.*/GRUB_TIMEOUT=0/' /etc/default/grub
# No fancy boot screen
grep -q rhgb /etc/default/grub && sed -e 's/rhgb //' /etc/default/grub
# Write out the config
grub2-mkconfig -o /boot/grub2/grub.cfg

# Ensure that cloud-init starts before sshd
FILE=/usr/lib/systemd/system/cloud-init.service
sed -i '/^Wants/s/$/ sshd.service/' $FILE
grep -q Before $FILE && sed -i '/Before/s/$/ sshd.service/' $FILE ||  sed -i '/\[Unit\]/aBefore=sshd.service' $FILE
