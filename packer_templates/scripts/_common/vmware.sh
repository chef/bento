#!/bin/bash -eux

# set a default HOME_DIR environment variable if not set
HOME_DIR="${HOME_DIR:-/home/vagrant}"

case "$PACKER_BUILDER_TYPE" in
vmware-iso|vmware-vmx)
  echo "installing open-vm-tools"
  if [ -f "/bin/dnf" ]; then
    dnf install -y open-vm-tools
    systemctl enable vmtoolsd
    systemctl start vmtoolsd
  elif [ -f "/usr/bin/apt-get" ]; then
    # determine the major Debian version we're runninng
    major_version="$(grep VERSION_ID /etc/os-release | awk -F= '{print $2}' | tr -d '"')"
    architecture="$(uname -m)"
    # open-vm-tools for amd64 are only available in bullseye-backports repo
    echo "install open-vm-tools"
    if [ "$major_version" -eq 11 ] && [ "$architecture" = "aarch64" ]; then
      echo 'deb http://deb.debian.org/debian bullseye-backports main' >> /etc/apt/sources.list
      apt-get update
      cat > /etc/modprobe.d/blacklist.conf <<EOF
blacklist vsock_loopback
blacklist vmw_vsock_virtio_transport_common
EOF
    fi
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
  echo "platform specific vmware.sh executed"
esac
