# frozen_string_literal: true

require 'spec_helper'
require 'bento/vagrant_freedos'

RSpec.describe Bento::VagrantFreedos::SyncedFolder do
  subject(:synced_folder) { described_class.new }

  let(:communicator) { double('communicator') }
  let(:vm_config) { double('vm_config', communicator: :freedos, guest: :freedos) }
  let(:config) { double('config', vm: vm_config) }
  let(:bs) { described_class::BS }
  let(:lf) { described_class::LF }
  let(:crlf) { described_class::CRLF }

  describe '#usable?' do
    it 'returns true for FreeDOS machines and false otherwise' do
      machine = double('machine', config: config)
      expect(synced_folder.usable?(machine)).to be(true)

      other = double('other', config: double('cfg', vm: double('vm', communicator: :ssh, guest: :linux)))
      expect(synced_folder.usable?(other)).to be(false)
      expect(synced_folder._initialize).to be_nil
      expect(synced_folder.capability?(:any)).to be(false)
      expect(synced_folder.disable(machine, {})).to be_nil
    end
  end

  describe '#prepare, #enable, #cleanup, and bidirectional sync' do
    it 'syncs host files to guest stage & disk and pulls guest artifacts back to host' do
      Dir.mktmpdir do |tmpdir|
        data_dir = File.join(tmpdir, '.vagrant_data')
        host_dir = File.join(tmpdir, 'workspace')
        FileUtils.mkdir_p(File.join(host_dir, '.git'))
        FileUtils.mkdir_p(File.join(host_dir, 'src'))
        File.write(File.join(host_dir, '.git', 'config'), 'ignored')
        File.write(File.join(host_dir, 'HELLO16.C'), "int main() {#{lf}  return 0;#{lf}}#{lf}")
        File.write(File.join(host_dir, 'src', 'UTIL.H'), "#define UTIL 1#{lf}")
        File.write(File.join(host_dir, 'DATA.BIN'), "\x00\x01\x02")

        machine = double('machine', config: config, data_dir: data_dir, communicate: communicator)
        folders = {
          '/vagrant' => {
            hostpath: host_dir,
            guestpath: '/vagrant',
            drive: 'D:',
            sync_direction: :bidirectional,
            crlf_convert: true,
            live_push: true,
            exclude: ['.git/']
          },
          '/disabled' => {
            hostpath: host_dir,
            disabled: true
          }
        }

        uploaded = []
        allow(communicator).to receive(:upload) do |src, dst|
          uploaded << [src, dst]
          true
        end

        synced_folder.prepare(machine, folders)
        expect(File.exist?(synced_folder.sync_disk_path(machine))).to be(true)
        expect(uploaded.map(&:last)).to include("D:#{bs}HELLO16.C", "D:#{bs}DATA.BIN")

        # Verify CRLF conversion occurred on .C file but not .BIN file
        staged_c = File.binread(File.join(synced_folder.guest_stage_dir(machine), 'HELLO16.C'))
        expect(staged_c).to include(crlf)
        staged_bin = File.binread(File.join(synced_folder.guest_stage_dir(machine), 'DATA.BIN'))
        expect(staged_bin).to eq("\x00\x01\x02")

        # Second sync with unchanged files should be a no-op
        synced_folder.enable(machine, folders)
        expect(synced_folder.sync_to_guest(machine, host_dir, folders['/vagrant'])).to eq([])

        # Simulate OpenWatcom generating HELLO16.EXE and OUT16.TXT inside the guest D: drive
        File.binwrite(File.join(synced_folder.guest_stage_dir(machine), 'HELLO16.EXE'), 'MZ_DOS_EXE')
        File.write(File.join(synced_folder.guest_stage_dir(machine), 'OUT16.TXT'), "Hello from DOS#{crlf}")

        synced_folder.cleanup(machine)
        expect(File.exist?(File.join(host_dir, 'HELLO16.EXE'))).to be(true)
        expect(File.binread(File.join(host_dir, 'HELLO16.EXE'))).to eq('MZ_DOS_EXE')
        expect(File.read(File.join(host_dir, 'OUT16.TXT'))).to include('Hello from DOS')
      end
    end

    it 'supports live_pull via communicator DIR and download' do
      Dir.mktmpdir do |tmpdir|
        data_dir = File.join(tmpdir, '.vagrant_data')
        host_dir = File.join(tmpdir, 'workspace')
        machine = double('machine', config: config, data_dir: data_dir, communicate: communicator)

        allow(communicator).to receive(:execute).with("DIR D:#{bs} /B", error_check: false) do |_c, _o, &blk|
          blk.call(:stdout, "RESULT.LOG#{lf}Volume in drive D#{lf}")
          0
        end
        allow(communicator).to receive(:download) do |_from, to|
          FileUtils.mkdir_p(File.dirname(to))
          File.write(to, 'WATCOM_TEST_PASS')
          true
        end

        pulled = synced_folder.sync_to_host(machine, host_dir, drive: 'D:', live_pull: true)
        expect(pulled).to include('RESULT.LOG')
        expect(File.read(File.join(host_dir, 'RESULT.LOG'))).to eq('WATCOM_TEST_PASS')
      end
    end

    it 'handles nil host_dir, to_host-only folders, and fallback data_dir when data_dir is nil' do
      bare_machine = double('bare', data_dir: nil)
      expect(synced_folder.sync_disk_path(bare_machine)).to include('bento_vagrant_freedos_default')
      expect(synced_folder.sync_to_guest(bare_machine, nil)).to eq([])
      expect(synced_folder.sync_to_host(bare_machine, nil)).to eq([])
      Dir.mktmpdir do |tmpdir|
        m_data = File.join(tmpdir, 'data')
        m_ws   = File.join(tmpdir, 'ws')
        FileUtils.mkdir_p(m_ws)
        m = double('m', data_dir: m_data)
        expect(synced_folder.sync_to_host(m, m_ws)).to eq([])

        to_host_folders = {
          '/host_only' => { hostpath: m_ws, sync_direction: :to_host },
          '/guest_only' => { hostpath: m_ws, sync_direction: :to_guest },
          '/dis' => { hostpath: m_ws, disabled: true }
        }
        synced_folder.prepare(m, to_host_folders)
        # Call prepare a second time when sync disk already exists
        synced_folder.prepare(m, to_host_folders)
        synced_folder.enable(m, to_host_folders)
        expect(described_class.sync_after_command(m)).to eq([])
      end
    end
  end
end

RSpec.describe Bento::VagrantFreedos::CommandSync do
  it 'parses flags and executes bidirectional, --to-guest, --to-host, and --watch sync' do
    Dir.mktmpdir do |tmpdir|
      data_dir = File.join(tmpdir, 'data')
      host_dir = File.join(tmpdir, 'ws')
      FileUtils.mkdir_p(host_dir)
      File.write(File.join(host_dir, 'TEST.C'), 'int x;')

      machine = double('machine', data_dir: data_dir)
      out = StringIO.new

      cmd_guest = described_class.new(['--to-guest', '--crlf'])
      expect(cmd_guest.execute_for_machine(machine, host_dir: host_dir, stdout: out)).to eq(0)
      expect(out.string).to include('Synced 1 file(s) to FreeDOS guest.')

      cmd_host = described_class.new(['--to-host'])
      expect(cmd_host.execute_for_machine(machine, host_dir: host_dir, stdout: out)).to eq(0)

      expect(described_class.synopsis).to include('synchronizes files')
      env_with_mach = double('env', active_machines: [[:default, :qemu]])
      allow(env_with_mach).to receive(:machine).with(:default, :qemu).and_return(machine)
      expect(described_class.new(['--to-host', 'default'], env_with_mach).execute(host_dir: host_dir, stdout: out)).to eq(0)
      env_empty = double('env_empty', active_machines: [])
      allow(env_empty).to receive(:machine)
      expect(described_class.new(['--to-host'], env_empty).execute(host_dir: host_dir, stdout: out)).to eq(0)
      expect(described_class.new(['--to-host'], nil).execute(host_dir: host_dir, stdout: out)).to eq(0)

      cmd_watch = described_class.new(['--watch', '--live', '--other'])
      parsed = cmd_watch.parse_argv(cmd_watch.argv)
      expect(parsed[:watch]).to be(true)
      expect(parsed[:live]).to be(true)
      allow(cmd_watch).to receive(:parse_argv).and_return(
        direction: :bidirectional, watch: true, live: false, crlf: false, iterations: 2, interval: 0.001
      )
      expect(cmd_watch.execute_for_machine(machine, host_dir: host_dir, stdout: out)).to eq(0)
    end
  end
end
