# remove root login from sshd
echo " "
echo " Removing root login over SSH "
echo " "
sed -i -e "s/PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
svcadm restart ssh

# update grub menu to lower timeout and remove unnecessary second entry
echo " "
echo " Updating Grub boot menu "
echo " "
sed -i -e 's/^timeout.*$/timeout 5/' -e "/^title omniosvar/,`wc -l /rpool/boot/grub/menu.lst | awk '{ print $1 }'` d" /rpool/boot/grub/menu.lst
