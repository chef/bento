#!/bin/sh -eux

# set a default HOME_DIR environment variable if not set
HOME_DIR="${HOME_DIR:-/home/vagrant}"
OS_NAME=$(uname -s)
if [ -f /etc/os-release ]; then
  OS_ID=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
fi

echo "installing updates"
if [ -f "/bin/dnf" ]; then
  dnf -y upgrade
elif [ -f "/usr/bin/apt-get" ]; then
  echo "disable systemd apt timers/services"
  systemctl stop apt-daily.timer
  systemctl stop apt-daily-upgrade.timer
  systemctl disable apt-daily.timer
  systemctl disable apt-daily-upgrade.timer
  systemctl mask apt-daily.service
  systemctl mask apt-daily-upgrade.service
  systemctl daemon-reload
  # Disable periodic activities of apt to be safe
  cat <<EOF >/etc/apt/apt.conf.d/10periodic
APT::Periodic::Enable "0";
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Download-Upgradeable-Packages "0";
APT::Periodic::AutocleanInterval "0";
APT::Periodic::Unattended-Upgrade "0";
EOF
  if [ "$OS_ID" = "ubuntu" ]; then
    echo "Detected Ubuntu"
    export DEBIAN_FRONTEND=noninteractive

    echo "disable release-upgrades"
    sed -i.bak 's/^Prompt=.*$/Prompt=never/' /etc/update-manager/release-upgrades

    echo "remove the unattended-upgrades and ubuntu-release-upgrader-core packages"
    rm -rf /var/log/unattended-upgrades;
    apt-get -y purge unattended-upgrades ubuntu-release-upgrader-core;

    echo "update the package list"
    apt-get -y update;

    echo "upgrade all installed packages incl. kernel and kernel headers"
    apt-get -y dist-upgrade -o Dpkg::Options::="--force-confnew";
  elif [ "$OS_ID" = "debian" ]; then
    echo "Detected Debian"
    arch="$(uname -r | sed 's/^.*[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}\(-[0-9]\{1,2\}\)-//')"
    apt-get update
    apt-get -y upgrade linux-image-"$arch"
    apt-get -y install linux-headers-"$(uname -r)"
  else
    echo "Unsupported OS: $OS_ID"
    exit 1
  fi
elif [ -f "/usr/bin/zypper" ]; then
  version=$(grep VERSION= /etc/os-release | cut -f2 -d\" | cut -f1 -d\ )

  zypper removerepo "openSUSE-${version}-0"

  zypper ar http://download.opensuse.org/distribution/leap/"${version}"/repo/oss/ openSUSE-Leap-"${version}"-Oss
  zypper ar http://download.opensuse.org/distribution/leap/"${version}"/repo/non-oss/ openSUSE-Leap-"${version}"-Non-Oss
  zypper ar http://download.opensuse.org/update/leap/"${version}"/oss/ openSUSE-Leap-"${version}"-Update
  zypper ar http://download.opensuse.org/update/leap/"${version}"/non-oss/ openSUSE-Leap-"${version}"-Update-Non-Oss

  zypper refresh
  zypper update -y
elif [ "$OS_NAME" = "FreeBSD" ]; then
  freebsd_update="/usr/sbin/freebsd-update --not-running-from-cron";

  # Update FreeBSD
  # NOTE: the install action fails if there are no updates so || true it
  env PAGER=/bin/cat "$freebsd_update" fetch || true;
  env PAGER=/bin/cat "$freebsd_update" install || true;

  # shellcheck disable=SC2154
  if [ "$pkg_branch" != "quarterly" ]; then
    sed -i.bak -e "s,pkg+http://pkg.FreeBSD.org/\${ABI}/quarterly,pkg+http://pkg.FreeBSD.org/\${ABI}/${pkg_branch}," /etc/pkg/FreeBSD.conf
    rm -f /etc/pkg/FreeBSD.conf.bak
  fi

  env ASSUME_ALWAYS_YES=true pkg update;
elif [ "$OS_NAME" = "Darwin" ]; then
  echo "Downloading and installing system updates..."
  sudo softwareupdate --agree-to-license -i -r -R --stdinpass vagrant
else
  echo "Unsupported OS: $OS_NAME"
  exit 1
fi

echo "updates installed rebooting"
reboot
sleep 60
