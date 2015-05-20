#!/bin/sh

if [ $PACKER_BUILDER_TYPE == 'virtualbox' ]; then
  echo "Installing VirtualBox Guest Additions"
  echo "mail=\ninstance=overwrite\npartial=quit" > /tmp/noask.admin
  echo "runlevel=nocheck\nidepend=quit\nrdepend=quit" >> /tmp/noask.admin
  echo "space=quit\nsetuid=nocheck\nconflict=nocheck" >> /tmp/noask.admin
  echo "action=nocheck\nbasedir=default" >> /tmp/noask.admin
  mkdir /mnt/vbga
  VBGADEV=`lofiadm -a VBoxGuestAdditions.iso`
  mount -o ro -F hsfs $VBGADEV /mnt/vbga
  pkgadd -a /tmp/noask.admin -G -d /mnt/vbga/VBoxSolarisAdditions.pkg all
  umount /mnt/vbga
  lofiadm -d $VBGADEV
  rm -f VBoxGuestAdditions.iso
fi

if [ $PACKER_BUILDER_TYPE == 'vmware' ]; then
  mkdir /mnt/vmtools
  VMTOOLSDEV=`lofiadm -a solaris.iso`
  mount -o ro -F hsfs $VMTOOLSDEV /mnt/vmtools
  mkdir /tmp/vmfusion-archive
  tar zxvf /mnt/vmtools/vmware-solaris-tools.tar.gz -C /tmp/vmfusion-archive
  /tmp/vmfusion-archive/vmware-tools-distrib/vmware-install.pl --default
  umount /mnt/vmtools
  lofiadm -d $VMTOOLSDEV
  rmdir /mnt/vmtools
  rm -rf /tmp/vmfusion-archive
  rm -f solaris.iso
fi
