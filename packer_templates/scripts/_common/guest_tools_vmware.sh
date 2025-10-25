#!/bin/bash -eux

# set a default HOME_DIR environment variable if not set
OS_NAME=$(uname -s)
if [ "$OS_NAME" = "Darwin" ]; then
  HOME_DIR="/Users/vagrant"
else
  HOME_DIR="${HOME_DIR:-/home/vagrant}"
fi

case "$PACKER_BUILDER_TYPE" in
vmware-iso|vmware-vmx)
  if [ "$OS_NAME" = "FreeBSD" ]; then
    pkg update
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

  REBOOT_NEEDED=false
  # Check for the /var/run/reboot-required file (common on Debian/Ubuntu)
  if [ -f /var/run/reboot-required ]; then
    REBOOT_NEEDED=true
  # Check for the needs-restarting command (common on RHEL based systems)
  elif command -v needs-restarting > /dev/null 2>&1; then
    # needs-restarting -r: indicates a full reboot is needed (exit code 1)
    # needs-restarting -s: indicates a service restart is needed (exit code 1)
    if needs-restarting -r > /dev/null 2>&1 || needs-restarting -s > /dev/null 2>&1; then
      REBOOT_NEEDED=true
    fi
  else
    echo "Unable to determine if a reboot is needed defaulting to reboot anyway"
    REBOOT_NEEDED=true
  fi

  if [ "$REBOOT_NEEDED" = true ]; then
    echo "pkgs installed needing reboot"
    shutdown -r now
    sleep 60
  else
    echo "no pkgs installed needing reboot"
  fi
  ;;
esac
