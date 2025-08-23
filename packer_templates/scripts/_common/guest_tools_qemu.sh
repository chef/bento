#!/bin/bash -eux

# set a default HOME_DIR environment variable if not set
OS_NAME=$(uname -s)
if [ "$OS_NAME" = "Darwin" ]; then
  HOME_DIR="/Users/vagrant"
else
  HOME_DIR="${HOME_DIR:-/home/vagrant}"
fi

case "$PACKER_BUILDER_TYPE" in
utm-iso)
  echo "installing pkgs necessary for UTM guest support"
  # We install things like spice-vdagent (clipboard sharing and dynamic display resolution )
  # QEMU Agent (time syncing and scripting are supported by the QEMU agent.)
  # SPICE WebDAV (QEMU directory sharing)
  if [ "$OS_NAME" = "FreeBSD" ]; then
    pkg update
    pkg install -y qemu-guest-agent
    cat >> /etc/rc.conf <<EOT
qemu_guest_agent_enable="YES"
EOT
    return
  elif [ -f "/bin/dnf" ]; then
    dnf install -y --skip-broken spice-vdagent qemu-guest-agent spice-webdavd
    sed -i 's/^BLACKLIST_RPC=/# BLACKLIST_RPC=/' /etc/sysconfig/qemu-ga # RHEL 8 instances
    sed -i 's/^FILTER_RPC_ARGS=/# FILTER_RPC_ARGS=/' /etc/sysconfig/qemu-ga # RHEL 9+ instances
    systemctl enable spice-vdagentd
    systemctl start spice-vdagentd
    systemctl enable spice-webdavd || true
    systemctl start spice-webdavd || true
  elif [ -f "/usr/bin/apt-get" ]; then
    apt-get update
    apt-get install -y spice-vdagent qemu-guest-agent spice-webdavd
    systemctl enable spice-vdagentd
    systemctl start spice-vdagentd
    systemctl enable spice-webdavd || true
    systemctl start spice-webdavd || true
  elif [ -f "/usr/bin/zypper" ]; then
    zypper install -y qemu-guest-agent
  fi
  systemctl enable qemu-guest-agent
  systemctl start qemu-guest-agent
  if [ -f /var/run/reboot-required ] || ! command -v needs-restarting -r 2>&1 /dev/null || ! command -v needs-restarting -s 2>&1 /dev/null; then
    echo "pkgs installed needing reboot"
    shutdown -r now
    sleep 60
  else
    echo "no pkgs installed needing reboot"
  fi
  ;;
qemu)
  echo "installing pkgs necessary for QEMU guest support"
  if [ "$OS_NAME" = "FreeBSD" ]; then
    pkg update
    pkg install -y qemu-guest-agent
    cat >> /etc/rc.conf <<EOT
qemu_guest_agent_enable="YES"
EOT
  elif [ -f "/bin/dnf" ]; then
    dnf install -y --skip-broken qemu-guest-agent
    sed -i 's/^BLACKLIST_RPC=/# BLACKLIST_RPC=/' /etc/sysconfig/qemu-ga # RHEL 8 instances
    sed -i 's/^FILTER_RPC_ARGS=/# FILTER_RPC_ARGS=/' /etc/sysconfig/qemu-ga # RHEL 9+ instances
  elif [ -f "/usr/bin/apt-get" ]; then
    apt-get update
    apt-get install -y qemu-guest-agent
  elif [ -f "/usr/bin/zypper" ]; then
    zypper install -y qemu-guest-agent
  fi
  systemctl enable qemu-guest-agent
  systemctl start qemu-guest-agent
  if [ -f /var/run/reboot-required ] || ! command -v needs-restarting -r 2>&1 /dev/null || ! command -v needs-restarting -s 2>&1 /dev/null; then
    echo "pkgs installed needing reboot"
    shutdown -r now
    sleep 60
  else
    echo "no pkgs installed needing reboot"
  fi
  ;;
esac
