#!/bin/sh -eux

OS_NAME=$(uname -s)
major_version="$(sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/redhat-release | awk -F. '{print $1}')"
distro="$(rpm -qf --queryformat '%{NAME}' /etc/redhat-release | cut -f 1 -d '-')"

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
        if [ "$major_version" -eq 10 ] && [ "$distro" = 'oraclelinux' ] && [ "$(uname -m)" = "aarch64" ]; then
          dnf -y install -- *epel-release*
          dnf -y install gcc-toolset-14 gcc-toolset-14-runtime gcc-toolset-14-gcc-c++
          mv /usr/bin/gcc /usr/bin/gcc.old
          ln -s /opt/rh/gcc-toolset-14/root/usr/bin/gcc /usr/bin/gcc
          dnf -y remove -- *epel-release*
        fi
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
hyperv-iso)
  echo "nothing to do for hyperv-iso"
  ;;
utm-iso|qemu)
  echo "nothing to do for utm or qemu"
  ;;
*)
  echo "Unknown Packer Builder Type >>$PACKER_BUILDER_TYPE<< selected."
  exit 0
  ;;
esac

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
fi

if [ "$REBOOT_NEEDED" = true ]; then
  echo "pkgs installed needing reboot"
  shutdown -r now
  sleep 60
else
  echo "no pkgs installed needing reboot"
fi
