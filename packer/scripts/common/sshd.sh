#!/bin/bash -eux

sed -i '/UseDNS/d' /etc/ssh/sshd_config
sed -i '/GSSAPIAuthentication/d' /etc/ssh/sshd_config

echo "UseDNS no" >> /etc/ssh/sshd_config
echo "GSSAPIAuthentication no" >> /etc/ssh/sshd_config
