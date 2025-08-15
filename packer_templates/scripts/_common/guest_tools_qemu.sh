#!/bin/bash -eux

# set a default HOME_DIR environment variable if not set
OS_NAME=$(uname -s)
if [ "$OS_NAME" = "Darwin" ]; then
  HOME_DIR="/Users/vagrant"
else
  HOME_DIR="${HOME_DIR:-/home/vagrant}"
fi

case "$PACKER_BUILDER_TYPE" in
utm-iso|qemu)
  echo "installing deps necessary for UTM guest support"
  # We install things like spice-vdagent (clipboard sharing and dynamic display resolution )
  # QEMU Agent (time syncing and scripting are supported by the QEMU agent.)
  # SPICE WebDAV (QEMU directory sharing)
  if [ -f "/bin/dnf" ]; then
    dnf install -y --skip-broken spice-vdagent qemu-guest-agent spice-webdavd
    systemctl enable spice-vdagentd
    systemctl start spice-vdagentd
    systemctl enable spice-webdavd
    systemctl start spice-webdavd
  elif [ -f "/usr/bin/apt-get" ]; then
    apt-get install -y spice-vdagent qemu-guest-agent spice-webdavd
    systemctl enable spice-vdagentd
    systemctl start spice-vdagentd
    systemctl enable spice-webdavd
    systemctl start spice-webdavd
  elif [ -f "/usr/bin/zypper" ]; then
    zypper install -y qemu-guest-agent
  fi
  systemctl enable qemu-guest-agent
  systemctl start qemu-guest-agent
  if [ -f /var/run/reboot-required ] || ! command -v needs-restarting -r &> /dev/null || ! command -v needs-restarting -s &> /dev/null; then
    echo "pkgs installed needing reboot"
    shutdown -r now
    sleep 60
  else
    echo "no pkgs installed needing reboot"
  fi
  ;;
esac
