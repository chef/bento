#!/bin/sh -eux

# set a default HOME_DIR environment variable if not set
OS_NAME=$(uname -s)
if [ "$OS_NAME" = "Darwin" ]; then
  HOME_DIR="/Users/vagrant"
else
  HOME_DIR="${HOME_DIR:-/home/vagrant}"
fi

case "$PACKER_BUILDER_TYPE" in
parallels-iso|parallels-pvm|parallels-ipsw)
  echo "Installing Parallels Tools..."
  if [ "$OS_NAME" = "FreeBSD" ]; then
    pkg update
    pkg install -y parallels-tools
  elif [ "$OS_NAME" = "Darwin" ]; then
    installer -pkg /Volumes/Parallels\ Tools/Install.app/Contents/Resources/Install.mpkg -target /
    # This usually works but gives a failed to eject error
    hdiutil detach /Volumes/Parallels\ Tools || echo "exit code $? is suppressed"
  elif ! ([ "$(uname -m)" = "aarch64" ] && [ -f /etc/os-release ] && (grep -qi 'opensuse' /etc/os-release || grep -qi 'sles' /etc/os-release)); then
    # Check kernel version
    KERNEL_VERSION=$(uname -r | cut -d. -f1,2)
    KERNEL_MAJOR=$(echo "$KERNEL_VERSION" | cut -d. -f1)
    KERNEL_MINOR=$(echo "$KERNEL_VERSION" | cut -d. -f2)
    if [ "$KERNEL_MAJOR" -lt 5 ] || ([ "$KERNEL_MAJOR" -eq 5 ] && [ "$KERNEL_MINOR" -lt 10 ]); then
      echo "Skipping Parallels Tools installation: kernel version $KERNEL_VERSION is below 5.10"
    else
      mkdir -p /tmp/parallels;
      if [ "$(uname -m)" = "aarch64" ] ; then
        mount -o loop "$HOME_DIR"/prl-tools-lin-arm.iso /tmp/parallels;
      else
        mount -o loop "$HOME_DIR"/prl-tools-lin.iso /tmp/parallels;
      fi
      VER="$(cat /tmp/parallels/version)";
      echo "Parallels Tools Version: $VER";
      /tmp/parallels/install --install-unattended-with-deps || (
        code="$?";
        echo "Parallels tools installation exited $code, attempting to output /var/log/parallels-tools-install.log";
        cat /var/log/parallels-tools-install.log;
        exit $code
      );
      umount /tmp/parallels;
      rm -rf /tmp/parallels;
      rm -f "$HOME_DIR"/*.iso;
      echo "removing kernel dev packages and compilers we no longer need"
      if command -v dnf >/dev/null 2>&1; then
        dnf remove -y install checkpolicy selinux-policy-devel gcc kernel-devel kernel-headers make
      fi
      shutdown -r now
      sleep 60
    fi
  else
    echo "Skipping Parallels Tools installation on aarch64 architecture for opensuse and derivatives"
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
