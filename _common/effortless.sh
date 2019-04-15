#!/bin/sh -eux

curl https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh | sudo bash
sudo groupadd hab
sudo useradd -g hab hab

echo 'Installing Effortless Config Linux Baseline package'
sudo hab pkg install effortless/config-baseline

echo 'Hardening and Patching OS with Effortless Config Linux Baseline package'
cd `hab pkg path effortless/config-baseline`
sudo echo "{\"bootstrap_mode\": true}" > /tmp/bootstrap.json
sudo hab pkg exec chef/chef-client chef-client -z -j /tmp/bootstrap.json -c config/bootstrap-config.rb
sudo rm /tmp/bootstrap.json

echo 'Installing Effortless Audit Linux Baseline package'
sudo hab pkg install effortless/audit-baseline

echo 'Verifying OS Compliance with Effortless Audit Linux Baseline package'
 sudo hab pkg exec chef/inspec inspec exec $(hab pkg path effortless/audit-baseline)/*.tar.gz --no-distinct-exit --json-config $(hab pkg path effortless/audit-baseline)/config/cli_only.json