#!/bin/bash

set -x
set -e

# Packages
# ------------------------------

# Delete old package states if present
rm -rf /var/lib/aptitude/pkgstates*

# Mark all packages as "Automatically installed"
aptitude -y markauto ~i --schedule-only

# Mark things we want to keep as a manual install - this is the most minimal
# running Ubuntu system I can package...
aptitude -y install --schedule-only \
  linux-generic \
  ubuntu-minimal \
  language-pack-en-base

# Remove all the other packages
aptitude -y install

# Be extra sure with apt
apt-get -y autoremove --purge
apt-get -y clean
apt-get -y autoclean

# Temporary files
# ------------------------------
# rm -rf /tmp/*

# Zero free space
# ------------------------------
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Bash history
# ------------------------------
unset HISTFILE
rm -f /root/.bash_history
rm -f /home/vagrant/.bash_history

# Log files
# ------------------------------
find /var/log -type f | while read f; do echo -ne '' > $f; done;

# Whiteout root
# ------------------------------
count=`df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}'`;
let count--
dd if=/dev/zero of=/tmp/whitespace bs=1024 count=$count;
rm /tmp/whitespace;

# Whiteout /boot
# ------------------------------
count=`df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}'`;
let count--
dd if=/dev/zero of=/boot/whitespace bs=1024 count=$count;
rm /boot/whitespace;

# Whiteout swaps
# ------------------------------
swappart=`cat /proc/swaps | tail -n1 | awk -F ' ' '{print $1}'`
swapoff $swappart;
dd if=/dev/zero of=$swappart;
mkswap $swappart;
swapon $swappart;

# Wait (othwerise Packer will cry)
# ------------------------------
sync
