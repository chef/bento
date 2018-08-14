#!/bin/sh -eux

for F in /etc/yum.repos.d/*.repo; do
  #sed --in-place=.orig 's/enabled=1/enabled=0/' $F
  echo "# EOL DISTRO - SETTINGS IN Bento-Vault.repo" > $F
done

cat <<_EOF_ | cat > /etc/yum.repos.d/Bento-Vault.repo
#BENTO-BEGIN
[C5.11-base]
name=CentOS-5.11 - Base
baseurl=http://vault.centos.org/5.11/os/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
enabled=1

[C5.11-updates]
name=CentOS-5.11 - Updates
baseurl=http://vault.centos.org/5.11/updates/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
enabled=1

[C5.11-extras]
name=CentOS-5.11 - Extras
baseurl=http://vault.centos.org/5.11/extras/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
enabled=1

[C5.11-centosplus]
name=CentOS-5.11 - Plus
baseurl=http://vault.centos.org/5.11/centosplus/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
enabled=1
#BENTO-END
_EOF_
