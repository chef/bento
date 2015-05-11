Vagrant.configure('2') do |config|
  config.ssh.insert_key = false
  config.vm.provider 'virtualbox' do |_, override|
    override.vm.synced_folder '.', '/vagrant', type: 'rsync'
  end
end
