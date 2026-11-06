# frozen_string_literal: true

require 'spec_helper'
require 'bento/vagrant_msdos'

RSpec.describe Bento::VagrantMsdos::Guest do
  subject(:guest) { described_class.new }

  let(:communicator) { double('communicator') }
  let(:machine) { double('machine', communicate: communicator) }

  describe '#detect? and #detect_version' do
    it 'returns true and detects versions 1.25, 2.0, and 4.0 from VER output' do
      allow(communicator).to receive(:execute).with('VER', error_check: false) do |_cmd, _opts, &block|
        block.call(:stdout, 'MS-DOS Version 1.25')
        block.call(:stderr, 'ignored')
        0
      end
      expect(guest.detect?(machine)).to be(true)
      expect(guest.detect_version(machine)).to eq('1.25')

      allow(communicator).to receive(:execute).with('VER', error_check: false) do |_cmd, _opts, &block|
        block.call(:stdout, 'Microsoft MS-DOS Version 2.00')
        0
      end
      expect(guest.detect_version(machine)).to eq('2.0')

      allow(communicator).to receive(:execute).with('VER', error_check: false) do |_cmd, _opts, &block|
        block.call(:stdout, 'MS-DOS Version 4.00')
        0
      end
      expect(guest.detect_version(machine)).to eq('4.0')
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
    it 'executes SHUTDOWN.COM and FDAPM.COM POWEROFF as individual commands without && chaining' do
      executed = []
      allow(communicator).to receive(:execute) do |cmd, _opts|
        executed << cmd
        0
      end
      expect(described_class.halt(machine)).to eq(0)
      expect(Bento::VagrantMsdos::GuestCapHalt.halt(machine)).to eq(0)
      expect(executed).to all(satisfy { |c| !c.include?('&&') })
      expect(executed.join("\n")).to include('SHUTDOWN.COM', 'FDAPM.COM POWEROFF')
    end
  end

  describe '.change_host_name and GuestCapChangeHostName' do
    it 'sanitizes the hostname to 15 chars and writes C:\BENTO\HOST.BAT or C:\HOST.BAT without && chaining' do
      executed = []
      allow(communicator).to receive(:execute) do |cmd, _opts|
        executed << cmd
        0
      end
      expect(described_class.change_host_name(machine, 'msdos-box-123456!')).to eq(0)
      expect(Bento::VagrantMsdos::GuestCapChangeHostName.change_host_name(machine, 'msdos-box-123456!')).to eq(0)
      expect(executed).to include('SET HOSTNAME=msdos-box-12345')
      expect(executed).to include("ECHO SET HOSTNAME=msdos-box-12345> C:#{92.chr}BENTO#{92.chr}HOST.BAT")
      expect(executed).to all(satisfy { |c| !c.include?('&&') })

      expect(described_class.change_host_name(machine, 'msdos-125', flat_root: true)).to eq(0)
      expect(executed).to include("ECHO SET HOSTNAME=msdos-125> C:#{92.chr}HOST.BAT")
    end
  end

  describe '.mount_shared_folder and GuestCapMountSharedFolder' do
    it 'tests that the target DOS drive responds to DIR' do
      expect(communicator).to receive(:test).with(include('DIR D:')).twice.and_return(true)
      expect(communicator).to receive(:test).with(include('DIR E:')).and_return(true)
      expect(described_class.mount_shared_folder(machine, 'D:')).to be(true)
      expect(Bento::VagrantMsdos::GuestCapMountSharedFolder.mount_shared_folder(machine, '/vagrant')).to be(true)
      expect(Bento::VagrantMsdos::GuestCapMountSharedFolder.mount_shared_folder(machine, 'E:')).to be(true)
    end
  end
end
