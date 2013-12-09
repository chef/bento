#!/bin/sh -x

set echo

#Set the time correctly
ntpdate -v -b in.pool.ntp.org

date > /etc/vagrant_box_build_time

# allow freebsd-update to run fetch without stdin attached to a terminal
sed 's/\[ ! -t 0 \]/false/' /usr/sbin/freebsd-update > /tmp/freebsd-update
chmod +x /tmp/freebsd-update

# update FreeBSD
env PAGER=/bin/cat /tmp/freebsd-update fetch
env PAGER=/bin/cat /tmp/freebsd-update install

#Install sudo, curl and ca_root_nss
pkg_add -r sudo curl ca_root_nss

# Emulate the ETCSYMLINK behavior of ca_root_nss; this is for FreeBSD 10, where fetch(1) was
# massively refactored and doesn't come with SSL CAcerts anymore
ln -sf /usr/local/share/certs/ca-root-nss.crt /etc/ssl/cert.pem

#Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
fetch -am -o authorized_keys 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub'
chown -R vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh

# As sharedfolders are not in defaults ports tree
# We will use vagrant via NFS
# Enable NFS
echo 'rpcbind_enable="YES"' >> /etc/rc.conf
echo 'nfs_server_enable="YES"' >> /etc/rc.conf
echo 'mountd_flags="-r"' >> /etc/rc.conf

# Enable passwordless sudo
echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /usr/local/etc/sudoers

# disable X11 because vagrants are (usually) headless
cat >> /etc/make.conf << EOT
WITHOUT_X11="YES"
EOT

pkg_add -r virtualbox-ose-additions virtio-kmod

# undo our customizations
sed -i '' -e '/^REFUSE /d' /etc/portsnap.conf

echo 'vboxdrv_load="YES"' >> /boot/loader.conf
echo 'vboxnet_enable="YES"' >> /etc/rc.conf
echo 'vboxguest_enable="YES"' >> /etc/rc.conf
echo 'vboxservice_enable="YES"' >> /etc/rc.conf

cat >> /boot/loader.conf << EOT
virtio_load="YES"
virtio_pci_load="YES"
virtio_blk_load="YES"
if_vtnet_load="YES"
virtio_balloon_load="YES"
EOT

# sed -i.bak -Ee 's|/dev/ada?|/dev/vtbd|' /etc/fstab
echo 'ifconfig_vtnet0_name="em0"' >> /etc/rc.conf
echo 'ifconfig_vtnet1_name="em1"' >> /etc/rc.conf
echo 'ifconfig_vtnet2_name="em2"' >> /etc/rc.conf
echo 'ifconfig_vtnet3_name="em3"' >> /etc/rc.conf

pw groupadd vboxusers
pw groupmod vboxusers -m vagrant

echo "=============================================================================="
echo "NOTE: FreeBSD - Vagrant"
echo "When using this basebox you need to do some special stuff in your Vagrantfile"
echo "1) Enable HostOnly network"
echo "	 config.vm.network ...."
echo "2) Use nfs instead of shared folders"
echo '		config.vm.share_folder("v-root", "/vagrant", ".", :nfs => true)'
echo "============================================================================="

exit
