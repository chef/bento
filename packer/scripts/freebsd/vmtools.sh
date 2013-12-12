#!/bin/sh

if [ $PACKER_BUILDER_TYPE == 'virtualbox' ]; then
  # disable X11 because vagrants are (usually) headless
  cat >> /etc/make.conf << EOT
  WITHOUT_X11="YES"
  EOT

  pkg_add -r virtualbox-ose-additions

  # undo our customizations
  sed -i '' -e '/^REFUSE /d' /etc/portsnap.conf

  echo 'vboxdrv_load="YES"' >> /boot/loader.conf
  echo 'vboxnet_enable="YES"' >> /etc/rc.conf
  echo 'vboxguest_enable="YES"' >> /etc/rc.conf
  echo 'vboxservice_enable="YES"' >> /etc/rc.conf

  cat >> /boot/loader.conf << EOT
  if_vtnet_load="YES"
  EOT

  echo 'ifconfig_vtnet0_name="em0"' >> /etc/rc.conf
  echo 'ifconfig_vtnet1_name="em1"' >> /etc/rc.conf
  echo 'ifconfig_vtnet2_name="em2"' >> /etc/rc.conf
  echo 'ifconfig_vtnet3_name="em3"' >> /etc/rc.conf
fi

if [ $PACKER_BUILDER_TYPE == 'vmware' ]; then
  mkdir /tmp/vmfusion
  mkdir /tmp/vmfusion-archive
  mdconfig -a -t vnode -f /home/vagrant/freebsd.iso -u 0
  mount -t cd9660 /dev/md0 /tmp/vmfusion
  tar xzf /tmp/vmfusion/vmware-freebsd-tools.tar.gz -C /tmp/vmfusion-archive
  pkg_add -r perl
  # Welcome to 2005. Have you heard of this "YouTube" thing?
  pkg_add -r compat6x-`uname -m`
  /tmp/vmfusion-archive/vmware-tools-distrib/vmware-install.pl --default

  echo 'ifconfig_vxn0="dhcp"' >> /etc/rc.conf
  umount /tmp/vmfusion
  rmdir /tmp/vmfusion
  rm -rf /tmp/vmfusion-archive
  rm /home/vagrant/freebsd.iso
fi
