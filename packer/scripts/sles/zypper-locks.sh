#!/bin/sh -eux

# remove zypper locks on removed packages to avoid later dependency problems
zypper --non-interactive ll | grep package | awk -F\| '{ print $2 }' | xargs -n 20 zypper --non-interactive rl
