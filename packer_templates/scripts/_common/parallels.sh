#!/bin/sh -eux

# set a default HOME_DIR environment variable if not set
HOME_DIR="${HOME_DIR:-/home/vagrant}";

case "$PACKER_BUILDER_TYPE" in
parallels-iso|parallels-pvm)
  if ! ([ "$(uname -m)" = "aarch64" ] && [ -f /etc/os-release ] && (grep -qi 'opensuse' /etc/os-release || grep -qi 'sles' /etc/os-release)); then
    if command -v dnf >/dev/null 2>&1; then
      dnf -y install checkpolicy selinux-policy-devel gcc kernel-devel kernel-headers make
    fi
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
  else
    echo "Skipping Parallels Tools installation on aarch64 architecture for opensuse and derivatives"
  fi
    ;;
esac
