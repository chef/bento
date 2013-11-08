#!/bin/bash -eux
yum -y erase gtk2 libX11 hicolor-icon-theme avahi freetype bitstream-vera-fonts kudzu
yum -y clean all
rm -rf VBoxGuestAdditions_*.iso VBoxGuestAdditions_*.iso.?
rm -f /tmp/chef*rpm

# BENTO-94: PAM unable to dlopen(/lib64/security/pam_fprintd.so)
authconfig --disablefingerprint --update

# clean up redhat interface persistence
rm -f /etc/udev/rules.d/70-persistent-net.rules
sed -i 's/^HWADDR.*$//' /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i 's/^UUID.*$//' /etc/sysconfig/network-scripts/ifcfg-eth0
