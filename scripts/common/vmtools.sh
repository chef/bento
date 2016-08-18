#!/bin/sh -eux

# set a default HOME_DIR environment variable if not set
HOME_DIR="${HOME_DIR:-/home/vagrant}";

case "$PACKER_BUILDER_TYPE" in

virtualbox-iso|virtualbox-ovf)
    VER="`cat /home/vagrant/.vbox_version`";

    echo "Virtualbox Tools Version: $VER";

    mkdir -p /tmp/vbox;
    mount -o loop $HOME_DIR/VBoxGuestAdditions_${VER}.iso /tmp/vbox;
    sh /tmp/vbox/VBoxLinuxAdditions.run \
        || echo "VBoxLinuxAdditions.run exited $? and is suppressed." \
            "For more read https://www.virtualbox.org/ticket/12479";
    umount /tmp/vbox;
    rm -rf /tmp/vbox;
    rm -f $HOME_DIR/*.iso;
    ;;

vmware-iso|vmware-vmx)
    ubuntu_version="`lsb_release -r | awk '{print $2}'`";
    ubuntu_major_version="`echo $ubuntu_version | awk -F. '{print $1}'`";
    redhat_version="`lsb_release -r | awk '{print $2}'`";
    redhat_major_version="`sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/redhat-release | awk -F. '{print $1}'`";

    # Use open-vm-tools
    if [ "$ubuntu_version" = "16.04" ]; then
        apt-get install -y open-vm-tools;
        mkdir /mnt/hgfs;
    elif [ -e /etc/redhat-release ] ; then
        wget http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-DSA-KEY.pub
        wget http://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub
        rpm --import ./VMWARE-PACKAGING-GPG-RSA-KEY.pub
        rpm --import ./VMWARE-PACKAGING-GPG-DSA-KEY.pub

        cat <<EOF>/etc/yum.repos.d/vmware.repo
[vmware-tools]
name=VMware Tools for $osname $releasever
baseurl=http://packages.vmware.com/tools/esx/5.5p08/rhel${major_version}/\$basearch
#baseurl=http://packages.vmware.com/tools/esx/5.5latest/rhel5/$basearch
enabled=1
gpgcheck=1
EOF
        yum install -y vmware-tools-esx vmware-tools-esx-kmods
    else
      mkdir -p /tmp/vmware;
      mkdir -p /tmp/vmware-archive;
      mount -o loop $HOME_DIR/linux.iso /tmp/vmware;

      TOOLS_PATH="`ls /tmp/vmware/VMwareTools-*.tar.gz`";
      VER="`echo "${TOOLS_PATH}" | cut -f2 -d'-'`";
      MAJ_VER="`echo ${VER} | cut -d '.' -f 1`";

      echo "VMware Tools Version: $VER";

      tar xzf ${TOOLS_PATH} -C /tmp/vmware-archive;
      if [ "${MAJ_VER}" -lt "10" ]; then
          /tmp/vmware-archive/vmware-tools-distrib/vmware-install.pl --default;
      else
          /tmp/vmware-archive/vmware-tools-distrib/vmware-install.pl --force-install;
      fi
      umount /tmp/vmware;
      rm -rf  /tmp/vmware;
      rm -rf  /tmp/vmware-archive;
      rm -f $HOME_DIR/*.iso;
    fi
    ;;

parallels-iso|parallels-pvm)
    mkdir -p /tmp/parallels;
    mount -o loop $HOME_DIR/prl-tools-lin.iso /tmp/parallels;
    VER="`cat /tmp/parallels/version`";

    echo "Parallels Tools Version: $VER";

    /tmp/parallels/install --install-unattended-with-deps \
      || (code="$?"; \
          echo "Parallels tools installation exited $code, attempting" \
          "to output /var/log/parallels-tools-install.log"; \
          cat /var/log/parallels-tools-install.log; \
          exit $code);
    umount /tmp/parallels;
    rm -rf /tmp/parallels;
    rm -f $HOME_DIR/*.iso;
    ;;

qemu)
    echo "Don't need anything for this one"
    ;;

*)
    echo "Unknown Packer Builder Type >>$PACKER_BUILDER_TYPE<< selected.";
    echo "Known are virtualbox-iso|virtualbox-ovf|vmware-iso|vmware-vmx|parallels-iso|parallels-pvm.";
    ;;

esac
