#!/bin/sh

set -eux

case "$PACKER_BUILDER_TYPE" in
   'virtualbox'*)
        ## https://access.redhat.com/site/solutions/58625 (subscription required)
        # add 'single-request-reopen' so it is included when /etc/resolv.conf is generated
        cat >> /etc/NetworkManager/dispatcher.d/fix-slow-dns <<EOF
        #!/bin/bash
        echo "options single-request-reopen" >> /etc/resolv.conf
        EOF
        chmod +x /etc/NetworkManager/dispatcher.d/fix-slow-dns
        systemctl restart NetworkManager.service
        echo 'Slow DNS fix applied (single-request-reopen)'
        ;;
    *)
        echo 'Slow DNS fix not required for this platform, skipping'
        ;;
esac
