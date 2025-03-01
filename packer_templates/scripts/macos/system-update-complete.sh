#!/bin/sh
set -euo pipefail
IFS=$'\n\t'
shopt -s nullglob nocaseglob

# wait for the update process to complete
if (grep "Action.*restart" ~/Library/Logs/packer_softwareupdate.log); then
  tail -f /var/log/install.log | sed '/.*Setup Assistant.*ISAP.*Done.*/ q' | grep ISAP || true
  sleep 180
fi

echo "Software update completed"
