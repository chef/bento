#!/bin/sh -eux

echo "UseDNS no" >>/etc/ssh/sshd_config;
echo "GSSAPIAuthentication no" >>/etc/ssh/sshd_config;
