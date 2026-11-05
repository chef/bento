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

  describe '.halt' do
    it 'executes SHUTDOWN.COM and FDAPM.COM POWEROFF over the communicator' do
      expect(communicator).to receive(:execute).with(
        include('SHUTDOWN.COM'),
        error_check: false
      ).and_return(0)
      expect(described_class.halt(machine)).to eq(0)
    end
  end

  describe '.change_host_name' do
    it 'sanitizes the hostname to 15 chars and writes C:\BENTO\HOST.BAT or C:\HOST.BAT on flat_root' do
      expect(communicator).to receive(:execute).with(
        include("C:#{92.chr}BENTO#{92.chr}HOST.BAT"),
        error_check: false
      ).and_return(0)
      expect(described_class.change_host_name(machine, 'msdos-box-123456!')).to eq(0)

      expect(communicator).to receive(:execute).with(
        include("C:#{92.chr}HOST.BAT"),
        error_check: false
      ).and_return(0)
      expect(described_class.change_host_name(machine, 'msdos-125', flat_root: true)).to eq(0)
    end
  end

  describe '.mount_shared_folder' do
    it 'tests that the target DOS drive responds to DIR' do
      expect(communicator).to receive(:test).with(include('DIR D:')).and_return(true)
      expect(described_class.mount_shared_folder(machine, 'D:')).to be(true)
    end
  end
end
