#!/bin/bash -eux

echo "UseDNS no" >> /etc/ssh/sshd_config
echo "GSSAPIAuthentication no" >> /etc/ssh/sshd_config
echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config
echo "KbdInteractiveAuthentication dno" >> /etc/ssh/sshd_config
