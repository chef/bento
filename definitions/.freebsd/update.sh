#!/usr/local/bin/bash -leux

pkg_add -r bsdadminscripts

sed -i '' -e 's/^# Defaults     env_keep += "PKG_PATH PKG_DBDIR PKG_TMPDIR TMPDIR PACKAGEROOT PACKAGESITE PKGDIR FTP_PASSIVE_MODE"/Defaults     env_keep += "PKG_PATH PKG_DBDIR PKG_TMPDIR TMPDIR PACKAGEROOT PACKAGESITE PKGDIR FTP_PASSIVE_MODE"/' /usr/local/etc/sudoers

echo "export PACKAGESITE=ftp://ftp.freebsd.org/pub/FreeBSD/ports/`uname -m`/packages-`uname -r | sed 's/^\(.\).*$/\1/'`-stable/Latest/" >> /etc/profile
echo "setenv PACKAGESITE ftp://ftp.freebsd.org/pub/FreeBSD/ports/`uname -m`/packages-`uname -r | sed 's/^\(.\).*$/\1/'`-stable/Latest/" >> /etc/csh.cshrc
. /etc/profile

pkg_upgrade -acbCf
