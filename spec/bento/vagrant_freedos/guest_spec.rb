# frozen_string_literal: true

require 'spec_helper'
require 'bento/vagrant_freedos'

RSpec.describe Bento::VagrantFreedos::Guest do
  subject(:guest) { described_class.new }

  let(:communicator) { double('communicator') }
  let(:machine) { double('machine', communicate: communicator) }

  describe '#detect?' do
    it 'returns true when VER output contains FreeDOS and exit code is 0' do
      allow(communicator).to receive(:execute).with('VER', error_check: false) do |_cmd, _opts, &block|
        block.call(:stdout, 'FreeCom version 0.85a - FreeDOS kernel 2043')
        block.call(:stderr, 'ignored')
        0
      end
      expect(guest.detect?(machine)).to be(true)
    end

    it 'returns false when exit code is non-zero or output does not match DOS' do
      allow(communicator).to receive(:execute).with('VER', error_check: false).and_return(1)
      expect(guest.detect?(machine)).to be(false)

      allow(communicator).to receive(:execute).with('VER', error_check: false) do |_cmd, _opts, &block|
        block.call(:stdout, 'Linux 6.12')
        0
      end
      expect(guest.detect?(machine)).to be(false)
    end
  end

  describe '.halt and GuestCapHalt' do
    it 'executes FDAPM.COM POWEROFF over the communicator' do
      expect(communicator).to receive(:execute).with(
        include('FDAPM.COM POWEROFF'),
        error_check: false
      ).twice.and_return(0)
      expect(described_class.halt(machine)).to eq(0)
      expect(Bento::VagrantFreedos::GuestCapHalt.halt(machine)).to eq(0)
    end
  end

  describe '.change_host_name and GuestCapChangeHostName' do
    it 'sanitizes the hostname to 15 chars and writes C:\BENTO\HOST.BAT' do
      expect(communicator).to receive(:execute).with(
        include('SET HOSTNAME=dos-test-box-12'),
        error_check: false
      ).twice.and_return(0)
      expect(described_class.change_host_name(machine, 'dos-test-box-123456!')).to eq(0)
      expect(Bento::VagrantFreedos::GuestCapChangeHostName.change_host_name(machine, 'dos-test-box-123456!')).to eq(0)
    end
  end

  describe '.mount_shared_folder and GuestCapMountSharedFolder' do
    it 'tests that the target DOS drive responds to DIR' do
      expect(communicator).to receive(:test).with(include('DIR D:')).twice.and_return(true)
      expect(communicator).to receive(:test).with(include('DIR E:')).and_return(true)
      expect(described_class.mount_shared_folder(machine, 'D:')).to be(true)
      expect(Bento::VagrantFreedos::GuestCapMountSharedFolder.mount_shared_folder(machine, '/vagrant')).to be(true)
      expect(Bento::VagrantFreedos::GuestCapMountSharedFolder.mount_shared_folder(machine, 'E:')).to be(true)
    end
  end
end
