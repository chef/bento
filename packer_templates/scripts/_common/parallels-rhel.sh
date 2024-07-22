#!/bin/sh -eux

# set a default HOME_DIR environment variable if not set
HOME_DIR="${HOME_DIR:-/home/vagrant}";

case "$PACKER_BUILDER_TYPE" in
parallels-iso|parallels-pvm)
    major_version="$(sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/redhat-release | awk -F. '{print $1}')"
    # make sure we use dnf on EL 8+
    if [ "$major_version" -ge 8 ]; then
      dnf -y install checkpolicy selinux-policy-devel gcc kernel-devel kernel-headers make
    else
      yum -y install checkpolicy selinux-policy-devel gcc kernel-devel kernel-headers make
    fi

    mkdir -p /tmp/parallels;
    if [ "$(uname -m)" = "aarch64" ] ; then
        if [ "$major_version" -eq 8 ]; then
          dnf -y install *epel-release*
          dnf -y install gcc-aarch64-linux-gnu gcc-c++-aarch64-linux-gnu gcc-toolset-12 gcc-toolset-12-runtime gcc-toolset-12-gcc-c++
          mv /usr/bin/gcc /usr/bin/gcc.old
          ln -s /opt/rh/gcc-toolset-12/root/usr/bin/gcc /usr/bin/gcc
          dnf -y install oracle-epel-release-el8
        fi

        mount -o loop "$HOME_DIR"/prl-tools-lin-arm.iso /tmp/parallels;
    else
        mount -o loop "$HOME_DIR"/prl-tools-lin.iso /tmp/parallels;
    fi
    VER="$(cat /tmp/parallels/version)";

    echo "Parallels Tools Version: $VER";

    /tmp/parallels/install --install-unattended-with-deps \
      || (code="$?"; \
          echo "Parallels tools installation exited $code, attempting" \
          "to output /var/log/parallels-tools-install.log"; \
          cat /var/log/parallels-tools-install.log; \
          exit $code);
    umount /tmp/parallels;
    rm -rf /tmp/parallels;
    rm -f "$HOME_DIR"/*.iso;
    ;;
esac
