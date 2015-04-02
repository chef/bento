#!/bin/bash -eux

UBUNTU_VERSION=`lsb_release -r | awk '{print $2}'`
# on 12.04 work around bad cached lists
if [[ "$UBUNTU_VERSION" == '12.04' ]]; then
  apt-get clean
  rm -rf /var/lib/apt/lists
fi

# Update the package list
apt-get update

# Upgrade all installed packages incl. kernel and kernel headers
apt-get -y upgrade linux-server linux-headers-server

# ensure the correct kernel headers are installed
# and packages from mtn_utils::packages
apt-get -y install linux-headers-$(uname -r) \
build-essential dkms zlib1g-dev \
apache2-utils unzip vim iotop libxml2-utils sysbench htop atop sysstat smartmontools nmap iftop \
git tmux openssh update-notifier-common

# begin updating package index immediately on boot
#cat <<EOF > /etc/init/refresh-apt.conf
#description "update package index"
#start on networking
#task
#exec /usr/bin/apt-get update
#EOF

# on 12.04 manage broken indexes on distro disc 12.04.5
if [[ $UBUNTU_VERSION == '12.04' ]]; then
  apt-get -y install libreadline-dev dpkg
  ## install chef and build some gems
  wget http://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chef_11.10.4-1.ubuntu.12.04_amd64.deb
  echo "Installing chef"
  dpkg -i chef_11.10.4-1.ubuntu.12.04_amd64.deb
fi


if [[ $UBUNTU_VERSION == '14.04' ]]; then
  ## install chef and build some gems
  wget http://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/13.04/x86_64/chef_11.10.4-1.ubuntu.13.04_amd64.deb
  echo "Installing chef"
  dpkg -i chef_11.10.4-1.ubuntu.13.04_amd64.deb
fi

# echo 'gem: --no-document' >> /root/.gemrc      ## for ruby 2.0+
echo 'gem: --no-ri --no-rdoc' >> /root/.gemrc  ## for ruby 1.9+

GEMS=(
    buff-extensions,0.3
    buff-extensions,1.0
    chef-rewind,0.0.8
    bundler,1.5.2
    berkshelf,2.0.18
    net-scp,1.2.1
)

for GEM in ${GEMS[@]} ; do 
    P=`echo $GEM | cut -d ',' -f 1`
    V=`echo $GEM | cut -d ',' -f 2`
    echo "Building Chef gem $P $V"
    /opt/chef/embedded/bin/gem install $P -v $V --no-ri --no-rdoc 
done

