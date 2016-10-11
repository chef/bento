#!/bin/sh -eux

freebsd_major="`uname -r | awk -F. '{print $1}'`";

case "$PACKER_BUILDER_TYPE" in

virtualbox-iso|virtualbox-ovf)
    # Disable X11 because vagrants are (usually) headless
    echo 'WITHOUT_X11="YES"' >> /etc/make.conf;

    pkg install -y virtualbox-ose-additions;

    echo 'vboxdrv_load="YES"' >>/boot/loader.conf;
    echo 'vboxnet_enable="YES"' >>/etc/rc.conf;
    echo 'vboxguest_enable="YES"' >>/etc/rc.conf;
    echo 'vboxservice_enable="YES"' >>/etc/rc.conf;

    echo 'virtio_blk_load="YES"' >>/boot/loader.conf;
    if [ "$freebsd_major" -gt 9 ]; then
      # Appeared in FreeBSD 10
      echo 'virtio_scsi_load="YES"' >>/boot/loader.conf;
    fi
    echo 'virtio_balloon_load="YES"' >>/boot/loader.conf;
    echo 'if_vtnet_load="YES"' >>/boot/loader.conf;

    echo 'ifconfig_vtnet0_name="em0"' >>/etc/rc.conf;
    echo 'ifconfig_vtnet1_name="em1"' >>/etc/rc.conf;
    echo 'ifconfig_vtnet2_name="em2"' >>/etc/rc.conf;
    echo 'ifconfig_vtnet3_name="em3"' >>/etc/rc.conf;

    pw groupadd vboxusers;
    pw groupmod vboxusers -m vagrant;
    ;;

vmware-iso|vmware-vmx)
    # Install Perl and other software needed by vmware-install.pl
    pkg install -y perl5;
    pkg install -y compat6x-`uname -m`;
    # the install script is very picky about location of perl command
    ln -s /usr/local/bin/perl /usr/bin/perl;

    mkdir -p /tmp/vmfusion;
    mkdir -p /tmp/vmfusion-archive;
    mdconfig -a -t vnode -f $HOME_DIR/freebsd.iso -u 0;
    mount -t cd9660 /dev/md0 /tmp/vmfusion;
    tar xzf /tmp/vmfusion/vmware-freebsd-tools.tar.gz -C /tmp/vmfusion-archive;
    /tmp/vmfusion-archive/vmware-tools-distrib/vmware-install.pl --default;
    echo 'ifconfig_vxn0="dhcp"' >>/etc/rc.conf;
    umount /tmp/vmfusion;
    rm -rf /tmp/vmfusion;
    rm -rf /tmp/vmfusion-archive;
    rm -f $HOME_DIR/*.iso;

    rm -f /usr/bin/perl;
    ;;

parallels-iso|parallels-pvm)
    echo "No current support for Parallels tools, continuing"
    ;;

*)
    echo "Unknown Packer Builder Type >>$PACKER_BUILDER_TYPE<< selected.";
    echo "Known are virtualbox-iso|virtualbox-ovf|vmware-iso|vmware-vmx|parallels-iso|parallels-pvm.";
    ;;

esac
