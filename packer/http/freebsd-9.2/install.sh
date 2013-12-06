#!/bin/sh -x

# Credit: http://www.aisecure.net/2011/05/01/root-on-zfs-freebsd-current/
#
# Heavily re-adapted from https://wiki.freebsd.org/RootOnZFS/GPTZFSBoot
# by Julian Dunn (jdunn@opscode.com) to remove legacy junk

NAME=$1

# create disks
# for variations in the root disk device name between VMware and Virtualbox
if [ -e /dev/ada0 ]; then
  DISKSLICE=ada0
else
  DISKSLICE=da0
fi

gpart create -s gpt $DISKSLICE
gpart add -b 34 -s 94 -t freebsd-boot $DISKSLICE
gpart add -t freebsd-zfs -l disk0 $DISKSLICE
gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 1 $DISKSLICE

zpool create -o altroot=/mnt -o cachefile=/tmp/zpool.cache zroot /dev/gpt/disk0
zpool set bootfs=zroot zroot

zfs set checksum=fletcher4 zroot

# set up zfs pools
zfs create zroot/usr
zfs create zroot/usr/home
zfs create zroot/var
zfs create -o compression=on   -o exec=on  -o setuid=off zroot/tmp
zfs create -o compression=lzjb             -o setuid=off zroot/usr/ports
zfs create -o compression=off  -o exec=off -o setuid=off zroot/usr/ports/distfiles
zfs create -o compression=off  -o exec=off -o setuid=off zroot/usr/ports/packages
zfs create -o compression=lzjb -o exec=off -o setuid=off zroot/usr/src
zfs create -o compression=lzjb -o exec=off -o setuid=off zroot/var/crash
zfs create                     -o exec=off -o setuid=off zroot/var/db
zfs create -o compression=lzjb -o exec=on  -o setuid=off zroot/var/db/pkg
zfs create                     -o exec=off -o setuid=off zroot/var/empty
zfs create -o compression=lzjb -o exec=off -o setuid=off zroot/var/log
zfs create -o compression=gzip -o exec=off -o setuid=off zroot/var/mail
zfs create                     -o exec=off -o setuid=off zroot/var/run
zfs create -o compression=lzjb -o exec=on  -o setuid=off zroot/var/tmp

# fixup
chmod 1777 /mnt/zroot/tmp
cd /mnt/zroot ; ln -s usr/home home
chmod 1777 /mnt/zroot/var/tmp

# set up swap
zfs create -V 2G zroot/swap
zfs set org.freebsd:swap=on zroot/swap
zfs set checksum=off zroot/swap
swapon /dev/zvol/zroot/swap

# Install the OS
cd /usr/freebsd-dist
cat base.txz | tar --unlink -xpJf - -C /mnt/zroot
cat lib32.txz | tar --unlink -xpJf - -C /mnt/zroot
cat kernel.txz | tar --unlink -xpJf - -C /mnt/zroot
cat src.txz | tar --unlink -xpJf - -C /mnt/zroot

cp /tmp/zpool.cache /mnt/zroot/boot/zfs/zpool.cache

zfs set readonly=on zroot/var/empty

# Enable required services
cat >> /mnt/zroot/etc/rc.conf << EOT
zfs_enable="YES"
hostname="${NAME}"
ifconfig_em0="dhcp"
sshd_enable="YES"
EOT

# Tune and boot from zfs
cat >> /mnt/zroot/boot/loader.conf << EOT
zfs_load="YES"
vfs.root.mountfrom="zfs:zroot"
vm.kmem_size="200M"
vm.kmem_size_max="200M"
vfs.zfs.arc_max="40M"
vfs.zfs.vdev.cache.size="5M"
EOT

# zfs doesn't use an fstab, but some rc scripts expect one
touch /mnt/zroot/etc/fstab

# Set up user accounts
zfs create zroot/usr/home/vagrant
echo "vagrant" | pw -V /mnt/zroot/etc useradd vagrant -h 0 -s /bin/sh -G wheel -d /home/vagrant -c "Vagrant User"
echo "vagrant" | pw -V /mnt/zroot/etc usermod root

chown 1001:1001 /mnt/zroot/home/vagrant

zfs unmount -a
zfs set mountpoint=legacy zroot
zfs set mountpoint=/tmp zroot/tmp
zfs set mountpoint=/usr zroot/usr
zfs set mountpoint=/var zroot/var

# Reboot
reboot
