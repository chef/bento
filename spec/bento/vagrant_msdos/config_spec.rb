# frozen_string_literal: true

require 'spec_helper'
require 'bento/vagrant_msdos'

RSpec.describe Bento::VagrantMsdos::Config do
  subject(:config) { described_class.new }

  describe '#initialize, #merge, #_finalize!, and #set_options' do
    it 'sets all attributes to UNSET_VALUE initially and supports merge, _finalize!, and set_options' do
      expect(config.host).to eq(described_class::UNSET_VALUE)
      expect(config.port).to eq(described_class::UNSET_VALUE)
      expect(config.serial_socket).to eq(described_class::UNSET_VALUE)
      expect(config.transport).to eq(described_class::UNSET_VALUE)
      expect(config.baud_rate).to eq(described_class::UNSET_VALUE)
      expect(config.boot_timeout).to eq(described_class::UNSET_VALUE)
      expect(config.command_timeout).to eq(described_class::UNSET_VALUE)
      expect(config.prompt_regex).to eq(described_class::UNSET_VALUE)
      expect(config.sync_drive).to eq(described_class::UNSET_VALUE)
      expect(config.work_dir).to eq(described_class::UNSET_VALUE)
      expect(config.dos_version).to eq(described_class::UNSET_VALUE)

      config.set_options(host: '127.0.0.2', port: 2325, unknown_opt: 'ignored')
      expect(config._finalize!).to be(true)

      other = described_class.new
      other.port = 2326
      merged = config.merge(other)
      expect(merged.host).to eq('127.0.0.2')
      expect(merged.port).to eq(2326)
      expect(merged.dos_version).to eq(described_class::UNSET_VALUE)
    end
  end

  describe '#finalize! and #supports_subdirectories?' do
    it 'assigns default values when unset and normalizes 4.00 to 4.0' do
      expect(config.supports_subdirectories?).to be(true)
      expect(config.host).to eq('127.0.0.1')
      expect(config.port).to eq(2324)
      expect(config.serial_socket).to be_nil
      expect(config.transport).to eq(:telnet)
      expect(config.baud_rate).to eq(115_200)
      expect(config.boot_timeout).to eq(60)
      expect(config.command_timeout).to eq(300)
      expect(config.prompt_regex).to be_a(Regexp)
      expect("C:#{92.chr}DOS>").to match(config.prompt_regex)
      expect('C>').to match(config.prompt_regex)
      expect(config.sync_drive).to eq('D:')
      expect(config.work_dir).to eq("D:#{92.chr}")
      expect(config.dos_version).to eq('4.0')

      cfg400 = described_class.new
      cfg400.dos_version = '4.00'
      cfg400.finalize!
      expect(cfg400.dos_version).to eq('4.0')
    end

    it 'returns false for supports_subdirectories? on MS-DOS 1.25 and true on 2.0 / 4.0' do
      config.dos_version = '1.25'
      config.finalize!
      expect(config.supports_subdirectories?).to be(false)

      config.dos_version = '2.0'
      config.finalize!
      expect(config.supports_subdirectories?).to be(true)
    end

    it 'preserves explicitly configured values' do
      config.host            = '10.0.0.8'
      config.port            = 4445
      config.serial_socket   = '/tmp/msdos.sock'
      config.transport       = :unix_socket
      config.baud_rate       = 9600
      config.boot_timeout    = 120
      config.command_timeout = 600
      config.prompt_regex    = />/
      config.sync_drive      = 'E:'
      config.work_dir        = "E:#{92.chr}SRC"
      config.dos_version     = '2.0'

      config.finalize!
      expect(config.host).to eq('10.0.0.8')
      expect(config.port).to eq(4445)
      expect(config.serial_socket).to eq('/tmp/msdos.sock')
      expect(config.transport).to eq(:unix_socket)
      expect(config.baud_rate).to eq(9600)
      expect(config.boot_timeout).to eq(120)
      expect(config.command_timeout).to eq(600)
      expect(config.prompt_regex).to eq(/>/)
      expect(config.sync_drive).to eq('E:')
      expect(config.work_dir).to eq("E:#{92.chr}SRC")
      expect(config.dos_version).to eq('2.0')
    end
  end

  describe '#validate' do
    it 'returns no errors for valid default configuration' do
      config.finalize!
      expect(config.validate(nil)).to eq({ 'msdos' => [] })
    end

    it 'reports an error when transport is invalid' do
      config.finalize!
      config.transport = :ssh
      errors = config.validate(nil)['msdos']
      expect(errors).not_to be_empty
      expect(errors.first).to include('Invalid transport')
    end

    it 'reports an error when telnet port is out of range or non-integer' do
      config.finalize!
      config.port = 0
      expect(config.validate(nil)['msdos'].join).to include('Invalid port')

      config.port = 70_000
      expect(config.validate(nil)['msdos'].join).to include('Invalid port')

      config.port = '2324'
      expect(config.validate(nil)['msdos'].join).to include('Invalid port')
    end

    it 'reports an error when transport is :unix_socket without serial_socket' do
      config.finalize!
      config.transport = :unix_socket
      config.serial_socket = nil
      expect(config.validate(nil)['msdos'].join).to include('serial_socket path must be provided')

      config.serial_socket = '   '
      expect(config.validate(nil)['msdos'].join).to include('serial_socket path must be provided')

      config.serial_socket = '/tmp/ok.sock'
      expect(config.validate(nil)['msdos']).to be_empty
    end

    it 'reports an error when sync_drive is not a valid DOS drive letter' do
      config.finalize!
      config.sync_drive = 'INVALID'
      expect(config.validate(nil)['msdos'].join).to include('Invalid sync_drive')

      config.sync_drive = 123
      expect(config.validate(nil)['msdos'].join).to include('Invalid sync_drive')
    end

    it 'reports an error when dos_version is unsupported' do
      config.finalize!
      config.dos_version = '3.30'
      expect(config.validate(nil)['msdos'].join).to include('Invalid dos_version')
    end
  end
end

RSpec.describe Bento::VagrantMsdos::Plugin do
  describe '.registered_components' do
    it 'exposes all MS-DOS Vagrant plugin components' do
      comps = described_class.registered_components
      expect(comps[:configs][:msdos]).to eq(Bento::VagrantMsdos::Config)
      expect(comps[:guests][:msdos]).to eq(Bento::VagrantMsdos::Guest)
      expect(comps[:guest_capabilities][:halt]).to eq(Bento::VagrantMsdos::GuestCapHalt)
      expect(comps[:communicators][:msdos]).to eq(Bento::VagrantMsdos::Communicator)
      expect(comps[:communicators][:msdos_serial]).to eq(Bento::VagrantMsdos::Communicator)
      expect(comps[:communicators][:msdos_telnet]).to eq(Bento::VagrantMsdos::Communicator)
      expect(comps[:synced_folders][:msdos_sync]).to eq(Bento::VagrantMsdos::SyncedFolder)
      expect(comps[:commands]['ssh']).to eq(Bento::VagrantMsdos::CommandSsh)
      expect(comps[:commands]['msdos-ssh']).to eq(Bento::VagrantMsdos::CommandSsh)
      expect(comps[:commands]['msdos-sync']).to eq(Bento::VagrantMsdos::CommandSync)
    end
  end

  describe '.register_with_vagrant!' do
    it 'returns false when Vagrant module is nil or does not respond to plugin' do
      expect(described_class.register_with_vagrant!(nil)).to be(false)
      expect(described_class.register_with_vagrant!(Module.new)).to be(false)
    end

    it 'registers all hooks when a Vagrant-compatible module is provided (with and without capabilities/action_hook)' do
      recorded = { configs: {}, guests: {}, caps: {}, communicators: {}, synced_folders: {}, commands: {}, hooks: [] }
      fake_hook = double('hook')
      allow(fake_hook).to receive(:before) { |target, mw| recorded[:hooks] << [target, mw] }

      fake_base = Class.new do
        define_singleton_method(:name) { |*_args| nil }
        define_singleton_method(:description) { |*_args| nil }
        define_singleton_method(:config) { |k, &blk| recorded[:configs][k] = blk.call }
        define_singleton_method(:guest) { |k, &blk| recorded[:guests][k] = blk.call }
        define_singleton_method(:guest_capability) { |g, c, &blk| recorded[:caps][[g, c]] = blk.call }
        define_singleton_method(:communicator) { |k, &blk| recorded[:communicators][k] = blk.call }
        define_singleton_method(:synced_folder) { |k, _p, &blk| recorded[:synced_folders][k] = blk.call }
        define_singleton_method(:command) { |k, &blk| recorded[:commands][k] = blk.call }
        define_singleton_method(:action_hook) { |_n, _a, &blk| blk.call(fake_hook) }
      end

      fake_builtin = Module.new do
        const_set(:SSHRun, :ssh_run_const)
        const_set(:SSHExec, :ssh_exec_const)
      end
      fake_action = Module.new do
        const_set(:Builtin, fake_builtin)
      end
      fake_vagrant = Module.new do
        const_set(:Action, fake_action)
        define_singleton_method(:plugin) { |_ver| fake_base }
      end

      expect(described_class.register_with_vagrant!(fake_vagrant)).to be(true)
      expect(recorded[:configs][:msdos]).to eq(Bento::VagrantMsdos::Config)
      expect(recorded[:guests][:msdos]).to eq(Bento::VagrantMsdos::Guest)
      expect(recorded[:caps][[:msdos, :halt]]).to eq(Bento::VagrantMsdos::GuestCapHalt)
      expect(recorded[:caps][[:msdos, :change_host_name]]).to eq(Bento::VagrantMsdos::GuestCapChangeHostName)
      expect(recorded[:caps][[:msdos, :mount_shared_folder]]).to eq(Bento::VagrantMsdos::GuestCapMountSharedFolder)
      expect(recorded[:communicators][:msdos]).to eq(Bento::VagrantMsdos::Communicator)
      expect(recorded[:synced_folders][:msdos_sync]).to eq(Bento::VagrantMsdos::SyncedFolder)
      expect(recorded[:commands]['ssh']).to eq(Bento::VagrantMsdos::CommandSsh)
      expect(recorded[:commands]['msdos-ssh']).to eq(Bento::VagrantMsdos::CommandSsh)
      expect(recorded[:commands]['msdos-sync']).to eq(Bento::VagrantMsdos::CommandSync)
      expect(recorded[:hooks]).to include([:ssh_run_const, Bento::VagrantMsdos::CommandSsh])
      expect(recorded[:hooks]).to include([:ssh_exec_const, Bento::VagrantMsdos::CommandSsh])

      # Also test minimal base class without guest_capability / action_hook
      minimal_base = Class.new do
        define_singleton_method(:name) { |*_args| nil }
        define_singleton_method(:description) { |*_args| nil }
        define_singleton_method(:config) { |*_args| nil }
        define_singleton_method(:guest) { |*_args| nil }
        define_singleton_method(:communicator) { |*_args| nil }
        define_singleton_method(:synced_folder) { |*_args| nil }
        define_singleton_method(:command) { |*_args| nil }
      end
      minimal_vagrant = Module.new do
        define_singleton_method(:plugin) { |_ver| minimal_base }
      end
      expect(described_class.register_with_vagrant!(minimal_vagrant)).to be(true)

      # Test top-level load when Vagrant constant is defined
      Object.const_set(:Vagrant, minimal_vagrant)
      begin
        load File.expand_path('../../../../lib/bento/vagrant_msdos.rb', __FILE__)
      ensure
        Object.send(:remove_const, :Vagrant)
      end
    end
  end
end
