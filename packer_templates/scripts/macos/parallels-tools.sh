#!/bin/sh

if [ -e .PACKER_BUILDER_TYPE ] || echo "$PACKER_BUILDER_TYPE" | grep -q '^parallels'; then
    echo "Installing Parallels Tools..."
    installer -pkg /Volumes/Parallels\ Tools/Install.app/Contents/Resources/Install.mpkg -target /

    # This usually works but gives a failed to eject error
    hdiutil detach /Volumes/Parallels\ Tools || echo "exit code $? is suppressed";

    # Reboot is needed for tools install
    reboot
fi
