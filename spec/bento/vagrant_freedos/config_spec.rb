# frozen_string_literal: true

require 'spec_helper'
require 'bento/vagrant_freedos'

RSpec.describe Bento::VagrantFreedos::Config do
  subject(:config) { described_class.new }

  describe '#initialize' do
    it 'sets all attributes to UNSET_VALUE initially' do
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
    end
  end

  describe '#finalize!' do
    it 'assigns default values when unset' do
      config.finalize!
      expect(config.host).to eq('127.0.0.1')
      expect(config.port).to eq(2323)
      expect(config.serial_socket).to be_nil
      expect(config.transport).to eq(:telnet)
      expect(config.baud_rate).to eq(115_200)
      expect(config.boot_timeout).to eq(60)
      expect(config.command_timeout).to eq(300)
      expect(config.prompt_regex).to be_a(Regexp)
      expect("C:#{92.chr}FDOS>").to match(config.prompt_regex)
      expect(config.sync_drive).to eq('D:')
      expect(config.work_dir).to eq("D:#{92.chr}")
    end

    it 'preserves explicitly configured values' do
      config.host            = '10.0.0.5'
      config.port            = 4444
      config.serial_socket   = '/tmp/custom.sock'
      config.transport       = :unix_socket
      config.baud_rate       = 9600
      config.boot_timeout    = 120
      config.command_timeout = 600
      config.prompt_regex    = />/
      config.sync_drive      = 'E:'
      config.work_dir        = "E:#{92.chr}SRC"

      config.finalize!
      expect(config.host).to eq('10.0.0.5')
      expect(config.port).to eq(4444)
      expect(config.serial_socket).to eq('/tmp/custom.sock')
      expect(config.transport).to eq(:unix_socket)
      expect(config.baud_rate).to eq(9600)
      expect(config.boot_timeout).to eq(120)
      expect(config.command_timeout).to eq(600)
      expect(config.prompt_regex).to eq(/>/)
      expect(config.sync_drive).to eq('E:')
      expect(config.work_dir).to eq("E:#{92.chr}SRC")
    end
  end

  describe '#validate' do
    it 'returns no errors for valid default configuration' do
      config.finalize!
      expect(config.validate(nil)).to eq({ 'freedos' => [] })
    end

    it 'reports an error when transport is invalid' do
      config.finalize!
      config.transport = :ssh
      errors = config.validate(nil)['freedos']
      expect(errors).not_to be_empty
      expect(errors.first).to include('Invalid transport')
    end

    it 'reports an error when telnet port is out of range or non-integer' do
      config.finalize!
      config.port = 0
      expect(config.validate(nil)['freedos'].join).to include('Invalid port')

      config.port = 70_000
      expect(config.validate(nil)['freedos'].join).to include('Invalid port')

      config.port = '2323'
      expect(config.validate(nil)['freedos'].join).to include('Invalid port')
    end

    it 'reports an error when transport is :unix_socket without serial_socket' do
      config.finalize!
      config.transport = :unix_socket
      config.serial_socket = nil
      expect(config.validate(nil)['freedos'].join).to include('serial_socket path must be provided')

      config.serial_socket = '   '
      expect(config.validate(nil)['freedos'].join).to include('serial_socket path must be provided')

      config.serial_socket = '/tmp/ok.sock'
      expect(config.validate(nil)['freedos']).to be_empty
    end

    it 'reports an error when sync_drive is not a valid DOS drive letter' do
      config.finalize!
      config.sync_drive = 'INVALID'
      expect(config.validate(nil)['freedos'].join).to include('Invalid sync_drive')

      config.sync_drive = 123
      expect(config.validate(nil)['freedos'].join).to include('Invalid sync_drive')
    end
  end
end

RSpec.describe Bento::VagrantFreedos::Plugin do
  describe '.registered_components' do
    it 'exposes all FreeDOS Vagrant plugin components' do
      comps = described_class.registered_components
      expect(comps[:configs][:freedos]).to eq(Bento::VagrantFreedos::Config)
      expect(comps[:guests][:freedos]).to eq(Bento::VagrantFreedos::Guest)
      expect(comps[:communicators][:freedos]).to eq(Bento::VagrantFreedos::Communicator)
      expect(comps[:communicators][:freedos_serial]).to eq(Bento::VagrantFreedos::Communicator)
      expect(comps[:communicators][:freedos_telnet]).to eq(Bento::VagrantFreedos::Communicator)
      expect(comps[:synced_folders][:freedos_sync]).to eq(Bento::VagrantFreedos::SyncedFolder)
      expect(comps[:commands]['freedos-ssh']).to eq(Bento::VagrantFreedos::CommandSsh)
      expect(comps[:commands]['freedos-sync']).to eq(Bento::VagrantFreedos::CommandSync)
    end
  end

  describe '.register_with_vagrant!' do
    it 'returns false when Vagrant module is nil or does not respond to plugin' do
      expect(described_class.register_with_vagrant!(nil)).to be(false)
      expect(described_class.register_with_vagrant!(Module.new)).to be(false)
    end

    it 'registers all hooks when a Vagrant-compatible module is provided' do
      recorded = { configs: {}, guests: {}, communicators: {}, synced_folders: {}, commands: {} }
      fake_base = Class.new do
        define_singleton_method(:name) { |*_args| nil }
        define_singleton_method(:description) { |*_args| nil }
        define_singleton_method(:config) { |k, &blk| recorded[:configs][k] = blk.call }
        define_singleton_method(:guest) { |k, &blk| recorded[:guests][k] = blk.call }
        define_singleton_method(:communicator) { |k, &blk| recorded[:communicators][k] = blk.call }
        define_singleton_method(:synced_folder) { |k, _p, &blk| recorded[:synced_folders][k] = blk.call }
        define_singleton_method(:command) { |k, &blk| recorded[:commands][k] = blk.call }
      end
      fake_vagrant = Module.new do
        define_singleton_method(:plugin) { |_ver| fake_base }
      end

      expect(described_class.register_with_vagrant!(fake_vagrant)).to be(true)
      expect(recorded[:configs][:freedos]).to eq(Bento::VagrantFreedos::Config)
      expect(recorded[:guests][:freedos]).to eq(Bento::VagrantFreedos::Guest)
      expect(recorded[:communicators][:freedos]).to eq(Bento::VagrantFreedos::Communicator)
      expect(recorded[:communicators][:freedos_serial]).to eq(Bento::VagrantFreedos::Communicator)
      expect(recorded[:communicators][:freedos_telnet]).to eq(Bento::VagrantFreedos::Communicator)
      expect(recorded[:synced_folders][:freedos_sync]).to eq(Bento::VagrantFreedos::SyncedFolder)
      expect(recorded[:commands]['freedos-ssh']).to eq(Bento::VagrantFreedos::CommandSsh)
      expect(recorded[:commands]['freedos-sync']).to eq(Bento::VagrantFreedos::CommandSync)
    end
  end
end
