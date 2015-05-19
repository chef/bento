#!/bin/bash -eux

if [[ "$PACKER_BUILDER_TYPE" == virtualbox* ]]; then
  # fix bug to enable nm-dispatcher on Fedora 19 https://bugzilla.redhat.com/show_bug.cgi?id=974811
  if [[ $(rpm -q --queryformat '%{VERSION}\n' fedora-release) == 19 ]]; then
    yum -y upgrade NetworkManager
    systemctl enable NetworkManager-dispatcher.service
  fi

  ## https://access.redhat.com/site/solutions/58625 (subscription required)
  # add 'single-request-reopen' so it is included when /etc/resolv.conf is generated
  cat >> /etc/NetworkManager/dispatcher.d/fix-slow-dns <<EOF
#!/bin/bash
echo "options single-request-reopen" >> /etc/resolv.conf
EOF
  chmod +x /etc/NetworkManager/dispatcher.d/fix-slow-dns
  service NetworkManager restart
  echo 'Slow DNS fix applied (single-request-reopen)'
else
  echo 'Slow DNS fix not required for this platform, skipping'
fi
