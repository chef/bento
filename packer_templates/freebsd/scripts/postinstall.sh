#!/bin/sh -eux

# Set the time correctly
ntpdate -v -b 0.freebsd.pool.ntp.org

# Install curl and ca_root_nss
pkg install -y curl ca_root_nss;

# Emulate the ETCSYMLINK behavior of ca_root_nss; this is for FreeBSD 10,
# where fetch(1) was massively refactored and doesn't come with
# SSL CAcerts anymore
ln -sf /usr/local/share/certs/ca-root-nss.crt /etc/ssl/cert.pem;

# Avoid pausing at the boot screen
cat >>/etc/loader.conf << LOADER_CONF
autoboot_delay="-1"
beastie_disable="YES"
LOADER_CONF

# disable crash dumps
sysrc dumpdev="NO"

# As sharedfolders are not in defaults ports tree, we will use NFS sharing
cat >>/etc/rc.conf << RC_CONF
rpcbind_enable="YES"
nfs_server_enable="YES"
mountd_flags="-r"
RC_CONF

echo 'Disable X11 in make.conf because Vagrants VMs are (usually) headless'
cat >>/etc/make.conf << MAKE_CONF
WITHOUT_X11="YES"
WITHOUT_GUI="YES"
MAKE_CONF

echo 'Update the locate DB'
/etc/periodic/weekly/310.locate
