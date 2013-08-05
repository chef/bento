#!/bin/bash -eux

sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=sudo' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers
