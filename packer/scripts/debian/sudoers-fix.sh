#!/bin/bash -eux

# Remove the includedir for sudoers. On older Ubuntu's (10.04), the includedir
# occurs BEFORE some other definitions. So it is impossible to set passwordless
# sudo for a user that belongs in the admin group (since later rules take
# precedence). These two lines remove the existing includedir and appends it at
# the very end of the file.
sed -i '/#includedir\ \/etc\/sudoers\.d/d' /etc/sudoers
echo ''                           >> /etc/sudoers
echo '#includedir /etc/sudoers.d' >> /etc/sudoers
echo ''                           >> /etc/sudoers
