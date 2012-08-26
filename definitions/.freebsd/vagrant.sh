#!/bin/sh -x

MAKE_OPS="-DWITHOUT_X11"

depends() {
  echo $1
  cd $1
  for d in $(make $MAKE_OPTS build-depends-list) ; do
    depends $d | xargs -n1 echo
  done  
}

sed 's/\[ ! -t 0 \]/false/' /usr/sbin/portsnap > /tmp/portsnap
chmod +x /tmp/portsnap
/tmp/portsnap fetch extract update

cd /usr/ports/emulators/virtualbox-ose-additions
for d in $(make $MAKE_OPTS build-depends-list) ; do
  echo $d
  depends $d | xargs -n1 echo
done | sort | uniq | awk -F'/' '{print $5}' | xargs pkg_add -r

cat >> /etc/make.conf << EOT
WITHOUT_X11="YES"
MASTER_SITE_OVERRIDE="http://ftp.freebsd.org/pub/FreeBSD/ports/distfiles/"
EOT

cd /usr/ports/emulators/virtualbox-ose-additions
make -DBATCH install clean

sed -i '' -e '/^MASTER_SITE_OVERRIDE/d' /etc/make.conf

cat >> /etc/rc.conf << EOT
vboxguest_enable="YES"
vboxservice_enable="YES"
EOT

service vboxguest start
service vboxservice start

mkdir /home/vagrant/.ssh
fetch -o /home/vagrant/.ssh/authorized_keys \
    'http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub'
chown -R vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh
