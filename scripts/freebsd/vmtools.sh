#!/bin/sh

freebsd_major=`uname -r | awk -F. '{ print $1 }'`
pkg_command="pkg install -y"
if [ $freebsd_major -gt 9 ]; then
  perl_pkg="perl5"
else
  perl_pkg="perl"
fi

if [ $PACKER_BUILDER_TYPE == 'virtualbox-iso' ]; then
  # disable X11 because vagrants are (usually) headless
  echo 'WITHOUT_X11="YES"' >> /etc/make.conf

  $pkg_command virtualbox-ose-additions

  echo 'vboxdrv_load="YES"' >> /boot/loader.conf
  echo 'vboxnet_enable="YES"' >> /etc/rc.conf
  echo 'vboxguest_enable="YES"' >> /etc/rc.conf
  echo 'vboxservice_enable="YES"' >> /etc/rc.conf

  echo 'virtio_blk_load="YES"' >> /boot/loader.conf
  if [ $freebsd_major -gt 9 ]; then
    # Appeared in FreeBSD 10
    echo 'virtio_scsi_load="YES"' >> /boot/loader.conf
  fi
  echo 'virtio_balloon_load="YES"' >> /boot/loader.conf
  echo 'if_vtnet_load="YES"' >> /boot/loader.conf

  echo 'ifconfig_vtnet0_name="em0"' >> /etc/rc.conf
  echo 'ifconfig_vtnet1_name="em1"' >> /etc/rc.conf
  echo 'ifconfig_vtnet2_name="em2"' >> /etc/rc.conf
  echo 'ifconfig_vtnet3_name="em3"' >> /etc/rc.conf
fi

if [ $PACKER_BUILDER_TYPE == 'vmware-iso' ]; then
  mkdir /tmp/vmfusion
  mkdir /tmp/vmfusion-archive
  mdconfig -a -t vnode -f /home/vagrant/freebsd.iso -u 0
  mount -t cd9660 /dev/md0 /tmp/vmfusion
  tar xzf /tmp/vmfusion/vmware-freebsd-tools.tar.gz -C /tmp/vmfusion-archive
  $pkg_command $perl_pkg
  # Welcome to 2005. Have you heard of this "YouTube" thing?
  $pkg_command compat6x-`uname -m`
  /tmp/vmfusion-archive/vmware-tools-distrib/vmware-install.pl --default

  echo 'ifconfig_vxn0="dhcp"' >> /etc/rc.conf
  umount /tmp/vmfusion
  rmdir /tmp/vmfusion
  rm -rf /tmp/vmfusion-archive
  rm /home/vagrant/freebsd.iso
fi
