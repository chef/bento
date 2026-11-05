#!/bin/sh
set -x
HTTPIP=$1
HTTPPORT=$2

wget http://${HTTPIP}:${HTTPPORT}/alpine/answers -O answers

# Find the installation disk (ignoring loops, cdroms, ramdisks)
DISK=$(ls /sys/block | grep -E '^sd|^vd|^nvme' | head -n 1)

sed -i "s|/dev/sda|/dev/$DISK|g" answers

setup-alpine -f answers <<ANSWERS
vagrant
vagrant
vagrant
vagrant
y
ANSWERS

# Wait for disk to settle
sleep 5

# Mount the root partition. sys install creates 3 partitions (boot, swap, root).
mount /dev/${DISK}3 /mnt
if [ $? -ne 0 ]; then
  mount /dev/${DISK}p3 /mnt
fi

echo 'PermitRootLogin yes' >> /mnt/etc/ssh/sshd_config
echo 'PasswordAuthentication yes' >> /mnt/etc/ssh/sshd_config

sed -i 's/^#\(http\)/\1/g' /mnt/etc/apk/repositories
chroot /mnt apk update

# Ensure user exists, set ash shell, set passwords
chroot /mnt adduser -D -s /bin/ash -g "" vagrant || true

# Add sudo and curl and configure sudo for vagrant
chroot /mnt apk add sudo curl
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /mnt/etc/sudoers

echo "vagrant:vagrant" | chroot /mnt chpasswd
echo "root:vagrant" | chroot /mnt chpasswd

umount /mnt
sync
sleep 5
reboot
