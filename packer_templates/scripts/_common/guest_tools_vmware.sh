#!/bin/bash -eux

# set a default HOME_DIR environment variable if not set
HOME_DIR="${HOME_DIR:-/home/vagrant}"
OS_NAME=$(uname -s)

case "$PACKER_BUILDER_TYPE" in
vmware-iso|vmware-vmx)
  if [ "$OS_NAME" = "FreeBSD" ]; then
    pkg install -y open-vm-tools-nox11
    # for shared folder
    echo 'fuse_load="YES"' >>/boot/loader.conf
    echo 'ifconfig_vmx0="dhcp"' >>/etc/rc.conf
  elif [ -f "/bin/dnf" ]; then
    dnf install -y open-vm-tools
    systemctl enable vmtoolsd
    systemctl start vmtoolsd
  elif [ -f "/usr/bin/apt-get" ]; then
    apt-get install -y open-vm-tools;
    mkdir /mnt/hgfs;
    systemctl enable open-vm-tools
    systemctl start open-vm-tools
  elif [ -f "/usr/bin/zypper" ]; then
    zypper install -y open-vm-tools insserv-compat
    mkdir /mnt/hgfs
    systemctl enable vmtoolsd
    systemctl start vmtoolsd
  fi
  echo "platform specific vmware.sh executed"
  reboot
  sleep 60
  ;;
esac
