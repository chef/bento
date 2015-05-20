# -*- mode: ruby -*-
# # vi: set ft=ruby :

Vagrant.require_version ">= 1.1.0"

Vagrant.configure("2") do |config|
  # Disable the base shared folder, Guest Tools are unavailable.
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provider :parallels do |prl|
    # Guest Tools are unavailable.
    prl.check_guest_tools = false
    prl.functional_psf    = false
  end
end
