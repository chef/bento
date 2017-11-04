#!/bin/bash -eux

# Add pkgadd auto-answer file
echo "mail=" > /tmp/nocheck
echo "instance=overwrite" >> /tmp/nocheck
echo "partial=nocheck" >> /tmp/nocheck
echo "runlevel=nocheck" >> /tmp/nocheck
echo "idepend=nocheck" >> /tmp/nocheck
echo "rdepend=nocheck" >> /tmp/nocheck
echo "space=nocheck" >> /tmp/nocheck
echo "setuid=nocheck" >> /tmp/nocheck
echo "conflict=nocheck" >> /tmp/nocheck
echo "action=nocheck" >> /tmp/nocheck
echo "basedir=default" >> /tmp/nocheck

echo "all" > /tmp/allfiles

if [ -f /home/vagrant/.vbox_version ]; then
    mkdir /tmp/vbox
    VER=$(cat /home/vagrant/.vbox_version)
    mkdir /cdrom
    VBGADEV=`lofiadm -a /home/vagrant/VBoxGuestAdditions.iso`
    mount -o ro -F hsfs $VBGADEV /cdrom
    pkgadd -a /tmp/nocheck -d /cdrom/VBoxSolarisAdditions.pkg < /tmp/allfiles
    umount /cdrom
    lofiadm -d $VBGADEV
    rm -f /home/vagrant/VBoxGuestAdditions.iso
else
    VMTOOLSDEV=`/usr/sbin/lofiadm -a /home/vagrant/solaris.iso`
    mkdir /cdrom
    mount -o ro -F hsfs $VMTOOLSDEV /cdrom
    mkdir /tmp/vmfusion-archive
    gtar zxvf /cdrom/vmware-solaris-tools.tar.gz -C /tmp/vmfusion-archive
    /tmp/vmfusion-archive/vmware-tools-distrib/vmware-install.pl --force-install
    umount /cdrom
    lofiadm -d $VMTOOLSDEV
    rm -rf /mnt/vmtools
    rm -rf /tmp/vmfusion-archive
    rm -f /home/vagrant/solaris.iso
fi
