#!/bin/sh -eux

OS_NAME=$(uname -s)

if [ "$OS_NAME" = "FreeBSD" ] || [ "$OS_NAME" = "Darwin" ]; then
  echo "Nothing to do for $OS_NAME"
  exit 0
fi

echo "Installing build tools for $PACKER_BUILDER_TYPE"

case "$PACKER_BUILDER_TYPE" in
parallels-iso|parallels-pvm)
  if ! ([ "$(uname -m)" = "aarch64" ] && [ -f /etc/os-release ] && (grep -qi 'opensuse' /etc/os-release || grep -qi 'sles' /etc/os-release)); then
    if command -v dnf >/dev/null 2>&1; then
      if [ -f /etc/fedora-release ]; then
        dnf -y install fuse-libs kernel-headers kernel-devel elfutils-libelf-devel gcc make perl
      else
        dnf install -y --skip-broken checkpolicy selinux-policy-devel gcc kernel-devel kernel-headers make kernel-uek-devel
      fi
    fi
  else
    echo "Skipping Parallels Tools installation on aarch64 architecture for opensuse and derivatives"
  fi
  ;;
virtualbox-iso|virtualbox-ovf)
  if ! ([ "$(uname -m)" = "aarch64" ] && [ -f /etc/os-release ] && (grep -qi 'opensuse' /etc/os-release || grep -qi 'sles' /etc/os-release)); then
    echo "installing deps necessary to compile kernel modules"
    # We install things like kernel-headers here vs. kickstart files so we make sure we install them for the updated kernel not the stock kernel
    if [ -f "/bin/dnf" ]; then
      dnf install -y --skip-broken perl cpp gcc make bzip2 tar kernel-headers kernel-devel kernel-uek-devel || true # not all these packages are on every system
    elif [ -f "/usr/bin/apt-get" ]; then
      apt-get install -y build-essential dkms bzip2 tar linux-headers-"$(uname -r)"
    elif [ -f "/usr/bin/zypper" ]; then
      zypper install -y perl cpp gcc make bzip2 tar kernel-default-devel
    fi
  else
    echo "Skipping Virtualbox guest additions installation on aarch64 architecture for opensuse and derivatives"
  fi
  ;;
*)
  echo "Unknown Packer Builder Type >>$PACKER_BUILDER_TYPE<< selected."
  ;;
esac

echo "build tools installed rebooting"
reboot
sleep 60
