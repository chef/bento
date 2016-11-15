#!/bin/sh -eux

MACOS_VERS=$(sw_vers -productVersion | awk -F "." '{print $2}')

if [ "$MACOS_VERS" -le 11 ] ; then
    softwareupdate --install --all;
fi

# --force became an option in 10.12 (Sierra) and will fail on other versions
if [ "$MACOS_VERS" -ge 12 ] ; then
    softwareupdate --background --force --verbose;
    softwareupdate --install --all --force --verbose;
    # vboxmanage_post commands fail without this sleep because the system
    # is not done with the softwareupdate background checks
    sleep 3;
fi
