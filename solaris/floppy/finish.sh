#!/bin/sh -x

BASE=/a

# copy our postinstall rc script
cp /tmp/install_config/s99startup.sh /a/etc/rc2.d/S99startup.sh
chmod +x /a/etc/rc2.d/S99startup.sh

# set up some paths for root (yeah some of these don't exist yet, but that's ok)
echo "if [ -f /etc/profile ]; then" >> /a/etc/skel/.bashrc
echo "        . /etc/profile" >> /a/etc/skel/.bashrc
echo "fi" >> /a/etc/skel/.bashrc

echo "if [ \"\$PS1\" ]; then" >> /a/etc/profile
echo "  if [ \"\$BASH\" ]; then" >> /a/etc/profile
echo "    PS1='\\u@\\h:\w\$ '" >> /a/etc/profile
echo "    if [ -f /etc/bash.bashrc ]; then" >> /a/etc/profile
echo "        . /etc/bash.bashrc" >> /a/etc/profile
echo "    fi" >> /a/etc/profile
echo "  else" >> /a/etc/profile
echo "    if [ \"\`id -u\`\" -eq 0 ]; then" >> /a/etc/profile
echo "      PS1='# '" >> /a/etc/profile
echo "    else" >> /a/etc/profile
echo "      PS1='\$ '" >> /a/etc/profile
echo "    fi" >> /a/etc/profile
echo "  fi" >> /a/etc/profile
echo "fi" >> /a/etc/profile
echo "PATH=/usr/local/bin:/usr/sfw/bin:/usr/ccs/bin:/usr/sbin:/usr/bin:\$PATH" >> /a/etc/profile
echo "export PATH" >> /a/etc/profile

echo "PATH=/usr/local/bin:/usr/sfw/bin:/usr/ccs/bin:/usr/sbin:/usr/bin" >> /a/etc/default/login
echo "SUPATH=/usr/local/bin:/usr/sfw/bin:/usr/ccs/bin:/usr/sbin:/usr/bin" >> /a/etc/default/login
