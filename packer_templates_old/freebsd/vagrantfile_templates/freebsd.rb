Vagrant.require_version ">= 1.1.0"

Vagrant.configure(2) do |config|
  config.ssh.shell = "sh"

  # Disable the base shared folder, Guest Tools supporting this feature are
  # unavailable for all providers.
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provider :parallels do |prl, override|
    # Guest Tools are unavailable.
    prl.check_guest_tools = false
    prl.functional_psf    = false
  end
end
