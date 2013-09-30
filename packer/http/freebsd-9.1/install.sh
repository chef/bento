#!/bin/sh -x

# Credit: http://www.aisecure.net/2011/05/01/root-on-zfs-freebsd-current/

NAME=$1

# create disks
gpart create -s gpt ada0
gpart add -b 34 -s 94 -t freebsd-boot ada0
gpart add -t freebsd-zfs -l disk0 ada0
gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 1 ada0

# align disks
gnop create -S 4096 /dev/gpt/disk0
zpool create -o altroot=/mnt -o cachefile=/tmp/zpool.cache zroot /dev/gpt/disk0.nop
zpool export zroot
gnop destroy /dev/gpt/disk0.nop
zpool import -o altroot=/mnt -o cachefile=/tmp/zpool.cache zroot

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
chmod 1777 /mnt/tmp
cd /mnt ; ln -s usr/home home
sleep 10
chmod 1777 /mnt/var/tmp

# set up swap
zfs create -V 2G zroot/swap
zfs set org.freebsd:swap=on zroot/swap
zfs set checksum=off zroot/swap

# Install the OS
cd /usr/freebsd-dist
cat base.txz | tar --unlink -xpJf - -C /mnt
cat lib32.txz | tar --unlink -xpJf - -C /mnt
cat kernel.txz | tar --unlink -xpJf - -C /mnt
cat src.txz | tar --unlink -xpJf - -C /mnt

cp /tmp/zpool.cache /mnt/boot/zfs/zpool.cache

sleep 10
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

# Set up user accounts
zfs create zroot/usr/home/vagrant
echo "vagrant" | pw -V /mnt/etc useradd vagrant -h 0 -s csh -G wheel -d /home/vagrant -c "Vagrant User"
echo "vagrant" | pw -V /mnt/etc usermod root

chown 1001:1001 /mnt/home/vagrant

# Reboot
reboot

