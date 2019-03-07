#!/bin/sh -eux

# should output one of 'redhat' 'centos' 'oraclelinux'
distro="`rpm -qf --queryformat '%{NAME}' /etc/redhat-release | cut -f 1 -d '-'`"

# Remove development and kernel source packages
yum -y remove gcc cpp kernel-devel kernel-headers;

if [ "$distro" != 'redhat' ]; then
  yum -y clean all;
fi

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

  echo "==> Setup /etc/rc.d/rc.local for CentOS7"
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
  nmcli c add type eth ifname \$gwdev con-name \$gwdev
fi
sed -i "/^#BENTO-BEGIN/,/^#BENTO-END/d" /etc/rc.d/rc.local
chmod -x /etc/rc.d/rc.local
#BENTO-END
_EOF_
  chmod +x /etc/rc.d/rc.local
fi

# delete any logs that have built up during the install
find /var/log/ -name *.log -exec rm -f {} \;

# remove previous kernels that yum preserved for rollback
# yum-utils isn't in RHEL 5 so don't try to run this
if ! lsb_release -a | grep -qE '^Release:\s*5'; then
  yum install -y yum-utils
  package-cleanup --oldkernels --count=1 -y
fi

# we try to remove these in the ks file, but they're still there
# in the builds so let's remove them here to be sure :shrug:
yum remove -y \
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
  zd1211-firmware
