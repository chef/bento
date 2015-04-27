#!/bin/bash -eux

/usr/bin/rsync -rv oak.osuosl.org::sshkey-unmanaged /tmp/
mkdir -p /root/.ssh /home/osuadmin/.ssh/
cp /tmp/authorized_keys.unmanaged /root/.ssh/authorized_keys
cp /tmp/authorized_keys.unmanaged /home/osuadmin/.ssh/authorized_keys
chown -R osuadmin:osuadmin /home/osuadmin/.ssh/
chmod 700 /root/.ssh /home/osuadmin/.ssh
chmod 600 /root/.ssh/authorized_keys /home/osuadmin/.ssh/authorized_keys
rm /tmp/authorized_keys.unmanaged
