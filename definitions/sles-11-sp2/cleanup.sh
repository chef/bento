#!/bin/bash -eux

# remove zypper locks on removed packages to avoid later dependency problems
zypper --non-interactive rl  \*
# zypper --non-interactive remove `rpm -qa virtualbox-guest-*` >/dev/null 2>&1
# Add an online copy of the SLES DVD1 as a software repository, instead of the mounted DVD
zypper removerepo 'SUSE-Linux-Enterprise-Server-11-SP2 11.2.2-1.234'
zypper addrepo 'http://demeter.uni-regensburg.de/SLES11SP2-x64/DVD1/' 'SLES11SP2-x64 DVD1 Online'
zypper refresh
