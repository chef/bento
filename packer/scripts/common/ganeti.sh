#!/bin/bash -eux

/usr/bin/rsync -rv oak.osuosl.org::sshkey-unmanaged /tmp/
mkdir -p /root/.ssh /home/osuadmin/.ssh/
cp /tmp/authorized_keys.unmanaged /root/.ssh/authorized_keys
cp /tmp/authorized_keys.unmanaged /home/osuadmin/.ssh/authorized_keys
chown -R osuadmin:osuadmin /home/osuadmin/.ssh/
chmod 700 /root/.ssh /home/osuadmin/.ssh
chmod 600 /root/.ssh/authorized_keys /home/osuadmin/.ssh/authorized_keys
rm /tmp/authorized_keys.unmanaged
yum -y install http://packages.osuosl.org/repositories/centos-7/osl/x86_64/denyhosts-2.6-19.el7.centos.noarch.rpm
chkconfig denyhosts on
sed -i -e 's/^PURGE_DENY.*/PURGE_DENY = 5d/' /etc/denyhosts.conf
