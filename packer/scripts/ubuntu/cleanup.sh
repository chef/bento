#!/bin/bash -eux

# Packages
# ------------------------------

# Specific linux kernels, such as: linux-image-3.11.0-15-generic but
#   * keep the current kernel
#   * do not touch the virtual packages, e.g.'linux-image-generic', etc.
dpkg --list | awk '{ print $2 }' | grep 'linux-image-3.*-generic' | grep -v `uname -r` | xargs apt-get -y purge

# Linux headers
dpkg --list | awk '{ print $2 }' | grep linux-headers | xargs apt-get -y purge
rm -rf /usr/src/linux-headers*

# Linux source
dpkg --list | awk '{ print $2 }' | grep linux-source | xargs apt-get -y purge

# Development packages
dpkg --list | awk '{ print $2 }' | grep -- '-dev$' | xargs apt-get -y purge

# Documentation packages
dpkg --list | awk '{ print $2 }' | grep -- '-doc$' | xargs apt-get -y purge

# Compilers
apt-get -y purge build-essential
dpkg --list | grep -i compiler | awk '{ print $2 }' | xargs apt-get -y purge

# Ruby
apt-get -y purge ruby ri rdoc

# Python
apt-get -y purge python-dbus libnl1 python-smartpm python-twisted-core libiw30 \
  python-twisted-bin libdbus-glib-1-2 python-pexpect python-pycurl \
  python-serial python-gobject python-pam python-openssl libffi5

# Compilers and other development tools
apt-get -y purge cpp gcc g++

# X11 libraries
apt-get -y purge libx11-data xauth libxmuu1 libxcb1 libx11-6 libxext6

# Obsolete networking
apt-get -y purge ppp pppconfig pppoeconf

# WTFs
apt-get -y purge popularity-contest installation-report landscape-common \
  wireless-tools wpasupplicant ubuntu-serverguide

# Be extra sure with apt
apt-get -y autoremove --purge
apt-get -y autoclean
apt-get -y clean

# Orphans
apt-get -y install deborphan
while [ -n "`deborphan --guess-all --libdevel`" ]; do
  deborphan --guess-all --libdevel | xargs apt-get -y purge
done
apt-get -y purge deborphan dialog

# Be extra sure with apt... again
apt-get -y autoremove --purge
apt-get -y autoclean
apt-get -y clean

# Locales
# ------------------------------
echo 'LANG="en_US.UTF-8"' > /etc/default/locale
echo 'LANGUAGE="en_US:"' >> /etc/default/locale

rm -rf /usr/share/locale/*
rm -rf /usr/share/locales/*
rm -rf /usr/lib/locale/*

locale-gen

# Temporary files
# ------------------------------
rm -rf /tmp/*

# Man pages
rm -rf /usr/share/man/*

# Remove APT files
find /var/lib/apt -type f | xargs rm -f

# Remove anything in /usr/src
rm -rf /usr/src/*

# Remove any docs
rm -rf /usr/share/doc/*

# Remove caches
find /var/cache -type f -exec rm -rf {} \;

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

# Erase free space
# ------------------------------
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Wait (othwerise Packer will cry)
# ------------------------------
sync
