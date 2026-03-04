#!/bin/sh -eux

# User 'vagrant' belongs to the 'users' group by default so we need to
# create a new group 'vagrant' and put our user there.

groupadd -f vagrant
gpasswd -a vagrant vagrant
