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
  elif [ "$OS_NAME" = "Darwin" ]; then
    # Globbing here: VMware Fusion >= 8.5.4 includes a second
    # 'darwinPre15.iso' for any OS X guests pre-10.11
    TOOLS_PATH=$(find "/Users/vagrant/" -name '*darwin*.iso' -print)
    if [ ! -e "$TOOLS_PATH" ]; then
        echo "Couldn't locate uploaded tools iso at $TOOLS_PATH!"
        exit 1
    fi
    TMPMOUNT=$(/usr/bin/mktemp -d /tmp/vmware-tools.XXXX)
    hdiutil attach "$TOOLS_PATH" -mountpoint "$TMPMOUNT"
    INSTALLER_PKG="$TMPMOUNT/Install VMware Tools.app/Contents/Resources/VMware Tools.pkg"
    if [ ! -e "$INSTALLER_PKG" ]; then
        echo "Couldn't locate VMware installer pkg at $INSTALLER_PKG!"
        exit 1
    fi
    echo "Installing VMware tools.."
    installer -pkg "$TMPMOUNT/Install VMware Tools.app/Contents/Resources/VMware Tools.pkg" -target /
    # This usually fails
    hdiutil detach "$TMPMOUNT" || echo "exit code $? is suppressed";
    rm -rf "$TMPMOUNT"
    rm -f "$TOOLS_PATH"
    # Point Linux shared folder root to that used by OS X guests,
    # useful for the Hashicorp vmware_fusion Vagrant provider plugin
    mkdir /mnt
    ln -sf /Volumes/VMware\ Shared\ Folders /mnt/hgfs
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
  shutdown -r now
  sleep 60
  ;;
esac
