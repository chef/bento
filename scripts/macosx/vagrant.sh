#!/bin/bash -eux

home_dir="$(python -c 'import pwd; print pwd.getpwnam("vagrant").pw_dir')"

if [ -f $home_dir/.vbox_version ]; then
    echo "VirtualBox not currently supported, sadface"
fi

if [ -f $home_dir/.vmfusion_version ]; then
    iso_name="$(uname | tr [[:upper:]] [[:lower:]]).iso"
    mount_point="$(mktemp -d /tmp/vmware-tools.XXXX)"
    #Run install, unmount ISO and remove it
    cd $home_dir
    hdiutil attach $iso_name -mountpoint "$mount_point"
    installer -pkg "$mount_point/Install VMware Tools.app/Contents/Resources/VMware Tools.pkg" -target /
    # This usually fails
    hdiutil detach "$mount_point" || true
    rm -rf $home_dir/$iso_name
    rmdir $mount_point

    # Point Linux shared folder root to that used by OS X guests,
    # useful for the Hashicorp vmware_fusion Vagrant provider plugin
    mkdir /mnt
    ln -sf /Volumes/VMware\ Shared\ Folders /mnt/hgfs
fi

pubkey_url='https://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub'
mkdir $home_dir/.ssh
if command -v wget >/dev/null ; then
    wget --no-check-certificate "$pubkey_url" -O $home_dir/.ssh/authorized_keys
elif command -v curl >/dev/null ; then
    curl --insecure --location "$pubkey_url" > $home_dir/.ssh/authorized_keys
else
    echo "Cannot download vagrant public key"
    exit 1
fi
chown -R vagrant $home_dir/.ssh
chmod -R go-rwsx $home_dir/.ssh
