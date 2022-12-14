#!/bin/sh -eux

# remove zypper locks on removed packages to avoid later dependency problems
zypper --non-interactive rl \*
