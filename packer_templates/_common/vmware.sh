#!/bin/sh -eux

# set a default HOME_DIR environment variable if not set
HOME_DIR="${HOME_DIR:-/home/vagrant}";

case "$PACKER_BUILDER_TYPE" in
vmware-iso|vmware-vmx)

    #!/bin/sh -eux

    # determine the major EL version we're runninng
    major_version="`sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/redhat-release | awk -F. '{print $1}'`";

    # make sure we use dnf on EL 8+
    if [ "$major_version" -ge 8 ]; then
      dnf -y install open-vm-tools
    else
      yum -y insttall open-vm-tools
    fi
    ;;
esac
