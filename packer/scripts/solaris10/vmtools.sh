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

echo "PATH = \$PATH"

if [ -f /home/vagrant/.vbox_version ]; then
    mkdir /tmp/vbox
    VER=$(cat /home/vagrant/.vbox_version)
    /opt/csw/bin/sudo mkdir /cdrom
    VBGADEV=`/opt/csw/bin/sudo /usr/sbin/lofiadm -a /home/vagrant/VBoxGuestAdditions.iso`
    /opt/csw/bin/sudo /usr/sbin/mount -o ro -F hsfs $VBGADEV /cdrom
    /opt/csw/bin/sudo /usr/sbin/pkgadd -a /tmp/nocheck -d /cdrom/VBoxSolarisAdditions.pkg < /tmp/allfiles
    /opt/csw/bin/sudo /usr/sbin/umount /cdrom
    /opt/csw/bin/sudo /usr/sbin/lofiadm -d $VBGADEV
    /opt/csw/bin/sudo rm -f /home/vagrant/VBoxGuestAdditions.iso
else
    VMTOOLSDEV=`/opt/csw/bin/sudo /usr/sbin/lofiadm -a /home/vagrant/solaris.iso`
    /opt/csw/bin/sudo mkdir /cdrom
    /opt/csw/bin/sudo /usr/sbin/mount -o ro -F hsfs $VMTOOLSDEV /cdrom
    /opt/csw/bin/sudo mkdir /tmp/vmfusion-archive
    /opt/csw/bin/sudo /opt/csw/bin/gtar zxvf /cdrom/vmware-solaris-tools.tar.gz -C /tmp/vmfusion-archive
    /opt/csw/bin/sudo /tmp/vmfusion-archive/vmware-tools-distrib/vmware-install.pl --default
    /opt/csw/bin/sudo /usr/sbin/umount /cdrom
    /opt/csw/bin/sudo /usr/sbin/lofiadm -d $VMTOOLSDEV
    /opt/csw/bin/sudo rm -rf /mnt/vmtools
    /opt/csw/bin/sudo rm -rf /tmp/vmfusion-archive
    /opt/csw/bin/sudo rm -f /home/vagrant/solaris.iso
fi
