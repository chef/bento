Vagrant.configure(2) do |config|
  # disabled until https://github.com/mitchellh/vagrant/pull/5326 makes it
  # into a release following 1.7.2
  config.ssh.insert_key = false

  config.vm.provider 'virtualbox' do |_, override|
    override.vm.synced_folder '.', '/vagrant', type: 'rsync'
  end
end
