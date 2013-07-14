#!/bin/bash -eux

sed -i -e '/Defaults\s\+env_reset/a Defaults\tsecure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"' /etc/sudoers
sed -i -e 's/%sudo ALL=(ALL) ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers
