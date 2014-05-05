#!/bin/bash -eux

if [[ $PACKER_BUILDER_TYPE =~ vmware ]]; then
  echo '==> Installling VMWare guest additions'

  cd /tmp
  mkdir -p /mnt/cdrom
  mount -o loop /home/vagrant/linux.iso /mnt/cdrom
  tar zxf /mnt/cdrom/VMwareTools-*.tar.gz -C /tmp/
  /tmp/vmware-tools-distrib/vmware-install.pl --default
  rm /home/vagrant/linux.iso
  umount /mnt/cdrom
  rmdir /mnt/cdrom
elif [[ $PACKER_BUILDER_TYPE =~ virtualbox ]]; then
  echo '==> Installling VirtualBox guest additions'

  VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
  mount -o loop /home/vagrant/VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
  sh /mnt/VBoxLinuxAdditions.run --nox11
  umount /mnt
  rm -rf /home/vagrant/VBoxGuestAdditions_$VBOX_VERSION.iso

  # http://stackoverflow.com/questions/22717428/vagrant-error-failed-to-mount-folders-in-linux-guest
  ln -s /opt/VBoxGuestAdditions-$VBOX_VERSION/lib/VBoxGuestAdditions /usr/lib/VBoxGuestAdditions
fi
