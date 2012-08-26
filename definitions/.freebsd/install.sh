#!/bin/sh -x

# Credit: http://www.aisecure.net/2011/05/01/root-on-zfs-freebsd-current/

NAME=$1

# create disks
gpart create -s gpt ada0
gpart add -b 34 -s 64k -t freebsd-boot ada0
gpart add -s 2G -t freebsd-swap -l swap0 ada0
gpart add -t freebsd-zfs -l disk0 ada0
gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 1 ada0

# set up zfs pools
zpool create zroot /dev/gpt/disk0
zpool set bootfs=zroot zroot
zfs set checksum=fletcher4 zroot
zfs set mountpoint=/mnt zroot
zfs create zroot/usr
zfs create zroot/usr/home
zfs create zroot/var
zfs create -o compression=on -o exec=on -o setuid=off zroot/tmp
zfs create -o compression=lzjb -o setuid=off zroot/usr/ports
zfs create -o compression=off -o exec=off -o setuid=off zroot/usr/ports/distfiles
zfs create -o compression=off -o exec=off -o setuid=off zroot/usr/ports/packages
zfs create -o compression=lzjb -o exec=off -o setuid=off zroot/usr/src
zfs create -o compression=lzjb -o exec=off -o setuid=off zroot/var/crash
zfs create -o exec=off -o setuid=off zroot/var/db
zfs create -o compression=lzjb -o exec=on -o setuid=off zroot/var/db/pkg
zfs create -o exec=off -o setuid=off zroot/var/empty
zfs create -o compression=lzjb -o exec=off -o setuid=off zroot/var/log
zfs create -o compression=gzip -o exec=off -o setuid=off zroot/var/mail
zfs create -o exec=off -o setuid=off zroot/var/run
zfs create -o compression=lzjb -o exec=on -o setuid=off zroot/var/tmp
zpool export zroot
zpool import -o cachefile=/tmp/zpool.cache zroot
chmod 1777 /mnt/tmp
cd /mnt ; ln -s usr/home home
chmod 1777 /mnt/var/tmp

# Install the OS
cd /usr/freebsd-dist
cat base.txz | tar --unlink -xpJf - -C /mnt
cat lib32.txz | tar --unlink -xpJf - -C /mnt
cat kernel.txz | tar --unlink -xpJf - -C /mnt
cat src.txz | tar --unlink -xpJf - -C /mnt

cp /tmp/zpool.cache /mnt/boot/zfs/zpool.cache

# Enable required services
cat >> /mnt/etc/rc.conf << EOT
zfs_enable="YES"
hostname="${NAME}"
ifconfig_em0="dhcp"
sshd_enable="YES"
EOT

# Tune and boot from zfs
cat >> /mnt/boot/loader.conf << EOT
zfs_load="YES"
vfs.root.mountfrom="zfs:zroot"
vm.kmem_size="200M"
vm.kmem_size_max="200M"
vfs.zfs.arc_max="40M"
vfs.zfs.vdev.cache.size="5M"
EOT

# Enable swap
echo '/dev/gpt/swap0 none swap sw 0 0' > /mnt/etc/fstab

# Install a few requirements
echo 'nameserver 8.8.8.8' > /mnt/etc/resolv.conf
pkg_add -C /mnt -r bash-static
(
  cd /mnt/bin
  ln -s /usr/local/bin/bash bash
  pkg_add -C /mnt -r sudo
  echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /mnt/usr/local/etc/sudoers
  rm /mnt/etc/resolv.conf
)

# Set up user accounts
zfs create zroot/usr/home/vagrant
echo "vagrant" | pw -V /mnt/etc useradd vagrant -h 0 -s csh -G wheel -d /home/vagrant -c "Vagrant User"
echo "vagrant" | pw -V /mnt/etc usermod root

chown 1001:1001 /mnt/home/vagrant

# Finalize zfs
zfs set readonly=on zroot/var/empty
zfs umount -a
zfs set mountpoint=legacy zroot
zfs set mountpoint=/tmp zroot/tmp
zfs set mountpoint=/usr zroot/usr
zfs set mountpoint=/var zroot/var

# Reboot
reboot

