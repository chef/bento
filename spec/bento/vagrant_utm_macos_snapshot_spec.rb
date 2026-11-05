# frozen_string_literal: true

require 'bento/vagrant_utm_macos_snapshot'

RSpec.describe Bento::VagrantUtmMacosSnapshot do
  let(:tmpdir) { Dir.mktmpdir }
  let(:vm_name) { 'bento-macos-14' }
  let(:machine_id) { '12345678-1234-1234-1234-123456789abc' }
  let(:item) { double('Item', name: vm_name, uuid: machine_id) }
  let(:list) { double('List', find: item) }
  let(:driver) do
    double('Driver',
           list: list,
           orig_create_snapshot: true,
           orig_delete_snapshot: true,
           orig_list_snapshots: ['qemu-snap'],
           orig_restore_snapshot: true)
  end

  after { FileUtils.rm_rf(tmpdir) }

  describe '.utm_documents_dir' do
    it 'returns path based on ENV["USER"] when present' do
      stub_const('ENV', ENV.to_hash.merge('USER' => 'testuser'))
      expect(described_class.utm_documents_dir).to eq('/Users/testuser/Library/Containers/com.utmapp.UTM/Data/Documents')
    end

    it 'falls back to Etc.getlogin when ENV["USER"] is nil' do
      stub_const('ENV', ENV.to_hash.except('USER'))
      allow(Etc).to receive(:getlogin).and_return('loginuser')
      expect(described_class.utm_documents_dir).to eq('/Users/loginuser/Library/Containers/com.utmapp.UTM/Data/Documents')
    end
  end

  describe '.apple_backend?' do
    it 'returns false if bundle directory does not exist' do
      expect(described_class.apple_backend?('nonexistent', tmpdir)).to be false
    end

    it 'returns true if Data/Data.img exists' do
      bundle = File.join(tmpdir, "#{vm_name}.utm")
      FileUtils.mkdir_p(File.join(bundle, 'Data'))
      File.write(File.join(bundle, 'Data', 'Data.img'), 'fake image')
      expect(described_class.apple_backend?(vm_name, tmpdir)).to be true
    end

    it 'returns true if root Data.img exists' do
      bundle = File.join(tmpdir, "#{vm_name}.utm")
      FileUtils.mkdir_p(bundle)
      File.write(File.join(bundle, 'Data.img'), 'fake image')
      expect(described_class.apple_backend?(vm_name, tmpdir)).to be true
    end

    it 'returns true if config.plist contains <string>Apple</string>' do
      bundle = File.join(tmpdir, "#{vm_name}.utm")
      FileUtils.mkdir_p(bundle)
      File.write(File.join(bundle, 'config.plist'), '<plist><string>Apple</string></plist>')
      expect(described_class.apple_backend?(vm_name, tmpdir)).to be true
    end

    it 'returns true if config.plist contains Backend key and Apple value' do
      bundle = File.join(tmpdir, "#{vm_name}.utm")
      FileUtils.mkdir_p(bundle)
      File.write(File.join(bundle, 'config.plist'), '<key>Backend</key><val>Apple</val>')
      expect(described_class.apple_backend?(vm_name, tmpdir)).to be true
    end

    it 'returns false if config.plist exists without Apple backend' do
      bundle = File.join(tmpdir, "#{vm_name}.utm")
      FileUtils.mkdir_p(bundle)
      File.write(File.join(bundle, 'config.plist'), '<key>Backend</key><string>QEMU</string>')
      expect(described_class.apple_backend?(vm_name, tmpdir)).to be false
    end

    it 'returns false if bundle directory exists but has no data or config' do
      bundle = File.join(tmpdir, "#{vm_name}.utm")
      FileUtils.mkdir_p(bundle)
      expect(described_class.apple_backend?(vm_name, tmpdir)).to be false
    end
  end

  describe '.snapshot_clone_name' do
    it 'formats clone name with vm name and snapshot name' do
      expect(described_class.snapshot_clone_name('myvm', 'clean')).to eq('myvm-snapshot-clean')
    end
  end

  describe '.execute_command' do
    it 'returns stripped stdout on success' do
      sout = instance_double(Mixlib::ShellOut, run_command: true, error?: false, stdout: "output line 
")
      allow(Mixlib::ShellOut).to receive(:new).with('echo test').and_return(sout)
      expect(described_class.execute_command('echo test')).to eq('output line')
    end

    it 'raises RuntimeError on failure' do
      sout = instance_double(Mixlib::ShellOut, run_command: true, error?: true, exitstatus: 1, stderr: 'bad command')
      allow(Mixlib::ShellOut).to receive(:new).with('bad cmd').and_return(sout)
      expect { described_class.execute_command('bad cmd') }.to raise_error(/Command 'bad cmd' failed with status 1: bad command/)
    end
  end

  describe '.resolve_machine_name' do
    it 'returns machine name when found in driver list' do
      expect(described_class.resolve_machine_name(driver, machine_id)).to eq(vm_name)
    end

    it 'raises if machine id cannot be resolved' do
      allow(list).to receive(:find).with(uuid: 'bad-id').and_return(nil)
      expect { described_class.resolve_machine_name(driver, 'bad-id') }.to raise_error(/Could not resolve machine name/)
    end
  end

  describe '.create_snapshot' do
    it 'clones VM using utmctl for Apple backend' do
      allow(described_class).to receive(:apple_backend?).with(vm_name).and_return(true)
      expect(described_class).to receive(:execute_command).with("utmctl clone \"#{vm_name}\" --name \"#{vm_name}-snapshot-snap1\"")
      described_class.create_snapshot(driver, machine_id, 'snap1')
    end

    it 'delegates to orig_create_snapshot for non-Apple backend' do
      allow(described_class).to receive(:apple_backend?).with(vm_name).and_return(false)
      expect(driver).to receive(:orig_create_snapshot).with(machine_id, 'snap1')
      described_class.create_snapshot(driver, machine_id, 'snap1')
    end
  end

  describe '.delete_snapshot' do
    it 'deletes clone using utmctl for Apple backend' do
      allow(described_class).to receive(:apple_backend?).with(vm_name).and_return(true)
      expect(described_class).to receive(:execute_command).with("utmctl delete \"#{vm_name}-snapshot-snap1\"")
      described_class.delete_snapshot(driver, machine_id, 'snap1')
    end

    it 'delegates to orig_delete_snapshot for non-Apple backend' do
      allow(described_class).to receive(:apple_backend?).with(vm_name).and_return(false)
      expect(driver).to receive(:orig_delete_snapshot).with(machine_id, 'snap1')
      described_class.delete_snapshot(driver, machine_id, 'snap1')
    end
  end

  describe '.list_snapshots' do
    it 'parses utmctl list output for Apple backend' do
      allow(described_class).to receive(:apple_backend?).with(vm_name).and_return(true)
      raw_output = <<~OUT
        UUID1 #{vm_name} running
        
        UUID2 #{vm_name}-snapshot-snap1 stopped
        UUID3 #{vm_name}-snapshot-snap2 stopped
        UUID4 other-vm stopped
        incomplete_line
      OUT
      allow(described_class).to receive(:execute_command).with('utmctl list').and_return(raw_output)
      expect(described_class.list_snapshots(driver, machine_id)).to eq(%w(snap1 snap2))
    end

    it 'delegates to orig_list_snapshots for non-Apple backend' do
      allow(described_class).to receive(:apple_backend?).with(vm_name).and_return(false)
      expect(driver).to receive(:orig_list_snapshots).with(machine_id).and_return(['orig-snap'])
      expect(described_class.list_snapshots(driver, machine_id)).to eq(['orig-snap'])
    end
  end

  describe '.restore_snapshot' do
    context 'for Apple backend' do
      before do
        allow(described_class).to receive(:apple_backend?).with(vm_name).and_return(true)
      end

      it 'raises error if target snapshot does not exist' do
        allow(described_class).to receive(:list_snapshots).with(driver, machine_id).and_return([])
        expect { described_class.restore_snapshot(driver, machine_id, 'missing') }.to raise_error(/Snapshot 'missing' does not exist/)
      end

      it 'stops active VM, deletes it, and clones snapshot back when snapshot exists' do
        allow(described_class).to receive(:list_snapshots).with(driver, machine_id).and_return(['snap1'])
        expect(described_class).to receive(:execute_command).with("utmctl stop \"#{vm_name}\"")
        expect(described_class).to receive(:execute_command).with("utmctl delete \"#{vm_name}\"")
        expect(described_class).to receive(:execute_command).with("utmctl clone \"#{vm_name}-snapshot-snap1\" --name \"#{vm_name}\"")
        described_class.restore_snapshot(driver, machine_id, 'snap1')
      end

      it 'rescues stop error if VM is already stopped' do
        allow(described_class).to receive(:list_snapshots).with(driver, machine_id).and_return(['snap1'])
        expect(described_class).to receive(:execute_command).with("utmctl stop \"#{vm_name}\"").and_raise(RuntimeError, 'already stopped')
        expect(described_class).to receive(:execute_command).with("utmctl delete \"#{vm_name}\"")
        expect(described_class).to receive(:execute_command).with("utmctl clone \"#{vm_name}-snapshot-snap1\" --name \"#{vm_name}\"")
        described_class.restore_snapshot(driver, machine_id, 'snap1')
      end
    end

    context 'for non-Apple backend' do
      it 'delegates to orig_restore_snapshot' do
        allow(described_class).to receive(:apple_backend?).with(vm_name).and_return(false)
        expect(driver).to receive(:orig_restore_snapshot).with(machine_id, 'snap1')
        described_class.restore_snapshot(driver, machine_id, 'snap1')
      end
    end
  end

  describe '.patch_driver! and .install!' do
    let(:fake_driver_class) do
      Class.new do
        def create_snapshot(_id, _name); :original_create; end
        def delete_snapshot(_id, _name); :original_delete; end
        def list_snapshots(_id); :original_list; end
        def restore_snapshot(_id, _name); :original_restore; end
      end
    end

    it 'patches driver methods and prevents duplicate patching' do
      described_class.patch_driver!(fake_driver_class)
      instance = fake_driver_class.new

      expect(described_class).to receive(:create_snapshot).with(instance, 'id1', 's1')
      instance.create_snapshot('id1', 's1')

      expect(described_class).to receive(:delete_snapshot).with(instance, 'id1', 's1')
      instance.delete_snapshot('id1', 's1')

      expect(described_class).to receive(:list_snapshots).with(instance, 'id1')
      instance.list_snapshots('id1')

      expect(described_class).to receive(:restore_snapshot).with(instance, 'id1', 's1')
      instance.restore_snapshot('id1', 's1')

      # Call patch again to verify idempotency guard branch
      described_class.patch_driver!(fake_driver_class)
    end

    it 'executes install! successfully when driver classes are defined' do
      stub_const('VagrantPlugins::Utm::Driver::Version_4_5', Class.new)
      stub_const('VagrantPlugins::Utm::Driver::Meta', Class.new)
      expect(described_class.install!).to be true
    end

    it 'executes install! successfully when driver classes are not defined' do
      hide_const('VagrantPlugins::Utm::Driver::Version_4_5')
      hide_const('VagrantPlugins::Utm::Driver::Meta')
      expect(described_class.install!).to be true
    end
  end
end
