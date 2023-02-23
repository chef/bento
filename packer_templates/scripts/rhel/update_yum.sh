#!/bin/sh -eux

yum -y upgrade --skip-broken;
reboot;
sleep 60;
