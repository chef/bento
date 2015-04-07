#!/bin/sh -x

freebsd_major=`uname -r | awk -F. '{ print $1 }'`

#Set the time correctly
ntpdate -v -b in.pool.ntp.org

date > /etc/vagrant_box_build_time

# allow freebsd-update to run fetch without stdin attached to a terminal
sed 's/\[ ! -t 0 \]/false/' /usr/sbin/freebsd-update > /tmp/freebsd-update
chmod +x /tmp/freebsd-update

# update FreeBSD
env PAGER=/bin/cat /tmp/freebsd-update fetch
env PAGER=/bin/cat /tmp/freebsd-update install

# always use pkgng - pkg_add is EOL as of 1 September 2014
env ASSUME_ALWAYS_YES=true pkg bootstrap
if [ $freebsd_major -lt 10 ]; then
  echo WITH_PKGNG=yes >> /etc/make.conf
fi

#Install sudo, curl and ca_root_nss
pkg update
pkg install -y sudo
pkg install -y curl
pkg install -y ca_root_nss

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

pw groupadd vboxusers
pw groupmod vboxusers -m vagrant

