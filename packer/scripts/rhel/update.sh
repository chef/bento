#!/bin/bash -eux

echo '==> Updating kernel'
yum update kernel
reboot

echo '==> Updating packages'
yum upgrade -y
