# add sudoers config for vagrant to have carte blanche on the system
echo " "
echo " Adding Vagrant user to sudoers "
echo " "
echo "vagrant ALL=(ALL) ALL" > /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant

echo " "
echo " Setting sudo to keep SSH_AUTH_SOCK by default "
echo " "
echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/keep_ssh_agent
chmod 0440 /etc/sudoers.d/keep_ssh_agent

# add paths and other options to vagrant user's shell
echo " "
echo " Setting Vagrant user's and root's environment "
echo " "
echo "export PATH=\$PATH:/opt/omni/bin" >> /export/home/vagrant/.profile
echo "export PATH=\$PATH:/opt/omni/bin" >> /root/.profile

# setup the vagrant key
# you can replace this key-pair with your own generated ssh key-pair
echo " "
echo " Setting the vagrant ssh pub key "
echo " "
mkdir /export/home/vagrant/.ssh
chmod 700 /export/home/vagrant/.ssh
chown vagrant:root /export/home/vagrant/.ssh
touch /export/home/vagrant/.ssh/authorized_keys
curl -sL http://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub > /export/home/vagrant/.ssh/authorized_keys
chmod 600 /export/home/vagrant/.ssh/authorized_keys
chown vagrant:root /export/home/vagrant/.ssh/authorized_keys
