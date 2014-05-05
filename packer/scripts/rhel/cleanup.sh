#!/bin/bash -eux

# Packages
# ------------------------------

echo '==> Removing development packages'
yum -y remove gcc cpp kernel-devel kernel-headers perl

echo '==> Removing wtf packages'
yum -y remove redhat-logos postfix

# Now really clean things
echo '==> Cleaning yum'
yum -y clean all

# Locales
# ------------------------------
echo '==> Cleaning locales'
find /usr/share/locale -type f | grep --invert-match en_US | xargs rm -rf

# Temporary files
# ------------------------------
echo '==> Cleaning temporary files'
rm -rf /tmp/*

# Man pages
rm -rf /usr/share/man/*

# Remove yum files
find /var/lib/yum -type f | xargs rm -f

# Remove anything in /usr/src
rm -rf /usr/src/*

# Remove any docs
rm -rf /usr/share/doc/*
rm -rf /usr/share/info/*

# Remove caches
find /var/cache -type f -exec rm -rf {} \;
rm -rf /usr/tmp/*

# Bash history
# ------------------------------
echo '==> Cleaning bash history'
history -c
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/vagrant/.bash_history

# Log files
# ------------------------------
echo '==> Cleaning log files'
rm -rf /var/log/wtmp
rm -rf /var/log/btmp
find /var/log -type f | while read f; do echo -ne '' > $f; done;

# Whiteout root
# ------------------------------
echo '==> Zeroing root'
count=`df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}'`;
let count--
dd if=/dev/zero of=/tmp/whitespace bs=1024 count=$count;
rm /tmp/whitespace;

# Whiteout /boot
# ------------------------------
echo '==> Zeroing boot'
count=`df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}'`;
let count--
dd if=/dev/zero of=/boot/whitespace bs=1024 count=$count;
rm /boot/whitespace;

# Erase free space
# ------------------------------
echo '==> Erasing free space to aid compression'
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Wait (othwerise Packer will cry)
# ------------------------------
sync
