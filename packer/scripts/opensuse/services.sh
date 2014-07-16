#!/bin/sh -eux

systemctl enable sshd
systemctl enable network
systemctl enable rsyslog