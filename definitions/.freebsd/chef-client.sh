#!/bin/sh -x

# Note: This is the RideCharge build of omnibux Chef. It is only for freebsd.
INSTALLER=https://dist.ridecharge.com/pub/chef/install.sh

fetch -q -o- ${INSTALLER} | sudo bash
