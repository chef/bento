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
  else
    echo "Skipping Parallels Tools installation on aarch64 architecture for opensuse and derivatives"
  fi

  if [ -f /var/run/reboot-required ] || ! command -v needs-restarting -r 2>&1 /dev/null || ! command -v needs-restarting -s 2>&1 /dev/null; then
    echo "pkgs installed needing reboot"
    shutdown -r now
    sleep 60
  else
    echo "no pkgs installed needing reboot"
  fi
  ;;
esac
