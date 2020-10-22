#!/bin/sh
# These were only needed for building VMware/Virtualbox extensions:
zypper --non-interactive rm --clean-deps gcc kernel-default-devel
zypper clean

# Clean up network interface persistence
rm -f /etc/udev/rules.d/70-persistent-net.rules;
touch /etc/udev/rules.d/75-persistent-net-generator.rules;

# truncate any logs that have built up during the install
find /var/log -type f -exec truncate --size=0 {} \;

# remove the contents of /tmp and /var/tmp
rm -rf /tmp/* /var/tmp/*

# force a new random seed to be generated
rm -f /var/lib/systemd/random-seed

# clear the history so our install isn't there
rm -f /root/.wget-hsts
export HISTSIZE=0