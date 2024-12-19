#!/bin/sh -eux

# set a default HOME_DIR environment variable if not set
HOME_DIR="${HOME_DIR:-/home/vagrant}";

case "$PACKER_BUILDER_TYPE" in
parallels-iso|parallels-pvm)
    mkdir -p /tmp/parallels;
    if [ "$(uname -m)" = "aarch64" ] ; then
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
