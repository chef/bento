#!/bin/csh -x
# NB: at the point when this script is run, vagrant's shell is csh

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

# allow portsnap to run fetch without stdin attached to a terminal
sed 's/\[ ! -t 0 \]/false/' /usr/sbin/portsnap > /tmp/portsnap
chmod +x /tmp/portsnap

# reduce the ports we extract to a minimum
cat >> /etc/portsnap.conf << EOT
REFUSE accessibility arabic archivers astro audio benchmarks biology cad
REFUSE chinese comms databases deskutils distfiles dns editors finance french
REFUSE ftp games german graphics hebrew hungarian irc japanese java korean
REFUSE mail math multimedia net net-im net-mgmt net-p2p news packages palm
REFUSE polish portuguese print russian science sysutils ukrainian
REFUSE vietnamese www x11 x11-clocks x11-drivers x11-fm x11-fonts x11-servers
REFUSE x11-themes x11-toolkits x11-wm
EOT

# get new ports
/tmp/portsnap fetch extract

# build package for sudo
pkg_delete -af
cd /usr/ports/security/sudo
make -DBATCH package-recursive clean

#Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
fetch -am -o authorized_keys 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub'
chown -R vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh

# Cleaning portstree to save space
# http://www.freebsd.org/doc/en_US.ISO8859-1/books/handbook/ports-using.html
cd /usr/ports/ports-mgmt/portupgrade
make install -DBATCH clean

/usr/local/sbin/portsclean -C

# As sharedfolders are not in defaults ports tree
# We will use vagrant via NFS
# Enable NFS
echo 'rpcbind_enable="YES"' >> /etc/rc.conf
echo 'nfs_server_enable="YES"' >> /etc/rc.conf
echo 'mountd_flags="-r"' >> /etc/rc.conf

# Enable passwordless sudo
echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /usr/local/etc/sudoers
# Restore correct su permissions
# I'll leave that up to the reader :)

# disable X11 because vagrants are (usually) headless
cat >> /etc/make.conf << EOT
WITHOUT_X11="YES"
EOT

cd /usr/ports/emulators/virtualbox-ose-additions
make -DBATCH package clean

cd /usr/ports/emulators/virtio-kmod
make -DBATCH install

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
