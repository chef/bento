#!/bin/sh -eux

# should output one of 'redhat' 'centos' 'oraclelinux'
distro="`rpm -qf --queryformat '%{NAME}' /etc/redhat-release | cut -f 1 -d '-'`"

major_version="`sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/redhat-release | awk -F. '{print $1}'`";

# make sure we use dnf on EL 8+
if [ "$major_version" -ge 8 ]; then
  pkg_cmd="dnf"
else
  pkg_cmd="yum"
fi

# remove previous kernels that yum/dnf preserved for rollback
if [ "$major_version" -ge 8 ]; then
  dnf autoremove -y
  dnf remove -y $(dnf repoquery --installonly --latest-limit=-1 -q)
elif [ "$major_version" -gt 5 ]; then # yum-utils isn't in RHEL 5 so don't try to run this
  if ! command -v package-cleanup >/dev/null 2>&1; then
  yum install -y yum-utils
  fi
  package-cleanup --oldkernels --count=1 -y
fi

# Remove development and kernel source packages
$pkg_cmd -y remove gcc cpp kernel-devel kernel-headers;

# Clean up network interface persistence
rm -f /etc/udev/rules.d/70-persistent-net.rules;
mkdir -p /etc/udev/rules.d/70-persistent-net.rules;
rm -f /lib/udev/rules.d/75-persistent-net-generator.rules;
rm -rf /dev/.udev/;

for ndev in `ls -1 /etc/sysconfig/network-scripts/ifcfg-*`; do
    if [ "`basename $ndev`" != "ifcfg-lo" ]; then
        sed -i '/^HWADDR/d' "$ndev";
        sed -i '/^UUID/d' "$ndev";
    fi
done

# new-style network device naming for centos7
if grep -q -i "release 7" /etc/redhat-release ; then
  # radio off & remove all interface configration
  nmcli radio all off
  /bin/systemctl stop NetworkManager.service
  for ifcfg in `ls /etc/sysconfig/network-scripts/ifcfg-* |grep -v ifcfg-lo` ; do
    rm -f $ifcfg
  done
  rm -rf /var/lib/NetworkManager/*

  echo "==> Setup /etc/rc.d/rc.local for EL7"
  cat <<_EOF_ | cat >> /etc/rc.d/rc.local
#BENTO-BEGIN
LANG=C
# delete all connection
for con in \`nmcli -t -f uuid con\`; do
  if [ "\$con" != "" ]; then
    nmcli con del \$con
  fi
done
# add gateway interface connection.
gwdev=\`nmcli dev | grep ethernet | egrep -v 'unmanaged' | head -n 1 | awk '{print \$1}'\`
if [ "\$gwdev" != "" ]; then
  nmcli connection add type ethernet ifname \$gwdev con-name \$gwdev
fi
sed -i "/^#BENTO-BEGIN/,/^#BENTO-END/d" /etc/rc.d/rc.local
chmod -x /etc/rc.d/rc.local
#BENTO-END
_EOF_
  chmod +x /etc/rc.d/rc.local
fi

# truncate any logs that have built up during the install
find /var/log -type f -exec truncate --size=0 {} \;

# we try to remove these in the ks file, but they're still there
# in the builds so let's remove them here to be sure :shrug:
#
# 12.2019 note: We can probably remove this now, but let's confirm it
$pkg_cmd remove -y \
  aic94xx-firmware \
  atmel-firmware \
  bfa-firmware \
  ipw2100-firmware \
  ipw2200-firmware \
  ivtv-firmware \
  iwl1000-firmware \
  iwl3945-firmware \
  iwl4965-firmware \
  iwl5000-firmware \
  iwl5150-firmware \
  iwl6000-firmware \
  iwl6050-firmware \
  kernel-uek-firmware \
  libertas-usb8388-firmware \
  netxen-firmware \
  ql2xxx-firmware \
  rt61pci-firmware \
  rt73usb-firmware \
  zd1211-firmware \
  linux-firmware \
  microcode_ctl

if [ "$distro" != 'redhat' ]; then
  $pkg_cmd -y clean all;
fi

# remove the install log
rm -f /root/anaconda-ks.cfg

# remove the contents of /tmp and /var/tmp
rm -rf /tmp/* /var/tmp/*

# Blank netplan machine-id (DUID) so machines get unique ID generated on boot.
if [ "$major_version" -ge 7 ]; then
  truncate -s 0 /etc/machine-id
fi

# clear the history so our install isn't there
export HISTSIZE=0
rm -f /root/.wget-hsts