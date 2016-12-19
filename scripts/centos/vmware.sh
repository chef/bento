#!/bin/sh -eux

# set a default HOME_DIR environment variable if not set
HOME_DIR="${HOME_DIR:-/home/vagrant}";

case "$PACKER_BUILDER_TYPE" in
vmware-iso|vmware-vmx)
    mkdir -p /tmp/vmware-archive;
    TOOLS_PATH="/tmp/VMwareTools-10.1.0-4449150.tar.gz";
    VER="`echo "${TOOLS_PATH}" | cut -f2 -d'-'`";
    MAJ_VER="`echo ${VER} | cut -d '.' -f 1`";

    echo "VMware Tools Version: $VER";

    tar xzf ${TOOLS_PATH} -C /tmp/vmware-archive;
	ls -alh /tmp/vmware-archive;
    if [ "${MAJ_VER}" -lt "10" ]; then
        /tmp/vmware-archive/vmware-tools-distrib/vmware-install.pl --default;
    else
        /tmp/vmware-archive/vmware-tools-distrib/vmware-install.pl --default --force-install;
    fi
    rm -rf  /tmp/vmware-archive;
    rm -rf /tmp/VMwareTools-10.1.0-4449150.tar.gz;
    rm -f $HOME_DIR/*.iso;
    ;;
esac
