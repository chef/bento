#!/bin/bash -eux

# On older releases, `/etc/sudoer` default with:
#   Defaults  requiredtty
# Which cause issue for sudo [1] and confirmed bug by Redhat [2]
# [1] https://github.com/mitchellh/vagrant/issues/1482
# [2] https://bugzilla.redhat.com/show_bug.cgi?id=1020147
sed -i -e 's/Defaults\s\+requiretty/#Default\trequiretty/g' /etc/sudoers

sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=sudo' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers
