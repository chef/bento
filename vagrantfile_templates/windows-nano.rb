# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.guest = :windows
  config.vm.communicator = "winrm"

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--hardwareuuid", "02f110e7-369a-4bbc-bbe6-6f0b6864ccb6"]
    vb.gui = true
    vb.memory = "1024"
  end

  config.vm.provider 'hyperv' do |hv|
    hv.ip_address_timeout = 240
  end
end
