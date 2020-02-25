#!/bin/sh -eux

# remove zypper locks on removed packages to avoid later dependency problems
any_package_locks=`zypper --non-interactive ll | grep package`;

if [ 'There are no package locks defined.' == "$any_package_locks" ]; then
  echo 'There are no package locks defined. Doing nothing.';
else
  zypper --non-interactive ll | grep package | awk -F\| '{ print $2 }' | xargs -n 20 zypper --non-interactive rl;
fi
