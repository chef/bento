# install the ports system
cd /tmp
wget "$MIRROR/pub/OpenBSD/`uname -r`/ports.tar.gz"

cd /usr
tar xzf /tmp/ports.tar.gz

rm /tmp/ports.tar.gz
