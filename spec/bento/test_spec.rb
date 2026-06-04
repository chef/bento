# frozen_string_literal: true

require 'kitchen'
require 'bento/test'

RSpec.describe TestRunner do
  let(:opts) { build_opts }

  subject(:runner) { described_class.new(opts) }

  # ── constructor ────────────────────────────────────────────────────────────

  describe '#initialize' do
    it 'sets provisioner to shell when nil' do
      expect(runner.provisioner).to eq('shell')
    end

    it 'uses a provided provisioner' do
      r = described_class.new(build_opts(provisioner: 'chef_zero'))
      expect(r.provisioner).to eq('chef_zero')
    end

    it 'starts with an empty errors array' do
      expect(runner.errors).to be_empty
    end

    it 'sets regx to nil when not provided' do
      expect(runner.regx).to be_nil
    end

    it 'stores the provided regx' do
      r = described_class.new(build_opts(regx: 'ubuntu-24'))
      expect(r.regx).to eq('ubuntu-24')
    end
  end

  # ── update_metadata_file (private helper) ──────────────────────────────────

  describe '#update_metadata_file (via send)' do
    let(:base_md) do
      {
        'name' => 'ubuntu-24.04', 'arch' => 'x86_64',
        'providers' => [
          { 'name' => 'virtualbox', 'file' => 'ubuntu-24.04-x86_64.virtualbox.box', 'testing' => 'passed' },
        ]
      }
    end

    it 'creates a new file with only the given provider (not all base_md providers)' do
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'test._metadata.json')
        new_provider = { 'name' => 'vmware_desktop', 'file' => 'ubuntu-24.04-x86_64.vmware.box', 'testing' => 'passed' }
        runner.send(:update_metadata_file, path, base_md, new_provider)
        written = JSON.parse(File.read(path))
        expect(written['providers'].map { |p| p['name'] }).to eq(['vmware_desktop'])
      end
    end

    it 'creates a new file when it does not exist' do
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'test._metadata.json')
        new_provider = { 'name' => 'vmware_desktop', 'file' => 'ubuntu-24.04-x86_64.vmware.box', 'testing' => 'passed' }
        runner.send(:update_metadata_file, path, base_md, new_provider)
        written = JSON.parse(File.read(path))
        expect(written['providers'].map { |p| p['name'] }).to include('vmware_desktop')
      end
    end

    it 'appends a new provider to an existing file without removing others' do
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'test._metadata.json')
        File.write(path, JSON.generate(base_md))
        new_provider = { 'name' => 'parallels', 'file' => 'ubuntu-24.04-x86_64.parallels.box', 'testing' => 'passed' }
        runner.send(:update_metadata_file, path, base_md, new_provider)
        written = JSON.parse(File.read(path))
        names = written['providers'].map { |p| p['name'] }
        expect(names).to include('virtualbox', 'parallels')
      end
    end

    it 'replaces an existing provider entry with the same name' do
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'test._metadata.json')
        File.write(path, JSON.generate(base_md))
        updated_provider = { 'name' => 'virtualbox', 'file' => 'ubuntu-24.04-x86_64.virtualbox.box', 'testing' => 'passed (retry)' }
        runner.send(:update_metadata_file, path, base_md, updated_provider)
        written = JSON.parse(File.read(path))
        vbox_entries = written['providers'].select { |p| p['name'] == 'virtualbox' }
        expect(vbox_entries.length).to eq(1)
        expect(vbox_entries.first['testing']).to eq('passed (retry)')
      end
    end

    it 'does not duplicate providers across multiple calls' do
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'test._metadata.json')
        provider = { 'name' => 'virtualbox', 'file' => 'f.box', 'testing' => 'passed' }
        runner.send(:update_metadata_file, path, base_md, provider)
        runner.send(:update_metadata_file, path, base_md, provider)
        written = JSON.parse(File.read(path))
        expect(written['providers'].count { |p| p['name'] == 'virtualbox' }).to eq(1)
      end
    end
  end

  # ── remove_from_build_complete (private helper) ───────────────────────────

  describe '#remove_from_build_complete (via send)' do
    let(:bc_md) do
      {
        'name' => 'ubuntu-2404', 'arch' => 'x86_64',
        'providers' => [
          { 'name' => 'virtualbox', 'file' => 'ubuntu-2404-x86_64.virtualbox.box' },
          { 'name' => 'parallels',  'file' => 'ubuntu-2404-x86_64.parallels.box' },
        ]
      }
    end

    it 'removes the named provider and rewrites the file' do
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'ubuntu-2404-x86_64._metadata.json')
        File.write(path, JSON.generate(bc_md))
        runner.send(:remove_from_build_complete, dir, 'ubuntu-2404-x86_64._metadata.json', 'virtualbox')
        data = JSON.parse(File.read(path))
        expect(data['providers'].map { |p| p['name'] }).to eq(['parallels'])
      end
    end

    it 'deletes the metadata file when the last provider is removed' do
      Dir.mktmpdir do |dir|
        single_provider_md = bc_md.merge('providers' => [{ 'name' => 'virtualbox', 'file' => 'f.box' }])
        path = File.join(dir, 'ubuntu-2404-x86_64._metadata.json')
        File.write(path, JSON.generate(single_provider_md))
        runner.send(:remove_from_build_complete, dir, 'ubuntu-2404-x86_64._metadata.json', 'virtualbox')
        expect(File.exist?(path)).to be false
      end
    end

    it 'does nothing when the metadata file does not exist' do
      Dir.mktmpdir do |dir|
        expect { runner.send(:remove_from_build_complete, dir, 'missing._metadata.json', 'virtualbox') }.not_to raise_error
      end
    end
  end

  # ── start ──────────────────────────────────────────────────────────────────

  describe '#start' do
    it 'raises with a list of failed files when errors exist' do
      allow(runner).to receive(:metadata_files).and_return(['fake._metadata.json'])
      allow(runner).to receive(:test_box) { runner.errors << 'fake.box' }
      expect { runner.start }.to raise_error(RuntimeError, /fake\.box/)
    end

    it 'completes without raising when all tests pass' do
      allow(runner).to receive(:metadata_files).and_return([])
      expect { runner.start }.not_to raise_error
    end
  end

  # ── test_box integration (light smoke) ────────────────────────────────────

  describe '#test_box' do
    let(:md) do
      {
        'name' => 'ubuntu-2404',
        'arch' => 'x86_64',
        'providers' => [{ 'name' => 'virtualbox', 'file' => 'ubuntu-2404-x86_64.virtualbox.box' }],
      }
    end

    it 'skips an instance that does not exist in kitchen config' do
      Dir.mktmpdir do |dir|
        # md_json must be a relative path (as returned by metadata_files)
        md_rel = 'ubuntu-2404-x86_64._metadata.json'
        File.write(File.join(dir, md_rel), JSON.generate(md))

        build_complete_dir = File.join(dir, 'builds', 'build_complete')
        FileUtils.mkdir_p(build_complete_dir)

        Dir.chdir(dir) do
          mock_config     = instance_double(Kitchen::Config)
          mock_collection = double('Kitchen::Collection')
          allow(Kitchen::Config).to receive(:new).and_return(mock_config)
          allow(mock_config).to receive(:instances).and_return(mock_collection)
          allow(mock_collection).to receive(:get).and_return(nil)
          allow(mock_collection).to receive(:each)

          expect { runner.send(:test_box, md_rel) }.not_to raise_error
          expect(runner.errors).to be_empty
        end
      end
    end

    it 'records a passing provider in the testing_passed metadata' do
      Dir.mktmpdir do |dir|
        md_rel = 'ubuntu-2404-x86_64._metadata.json'
        File.write(File.join(dir, md_rel), JSON.generate(md))

        build_complete_dir = File.join(dir, 'builds', 'build_complete')
        FileUtils.mkdir_p(build_complete_dir)
        File.write(File.join(build_complete_dir, 'ubuntu-2404-x86_64.virtualbox.box'), 'fake')

        Dir.chdir(dir) do
          mock_instance   = instance_double(Kitchen::Instance)
          mock_config     = instance_double(Kitchen::Config)
          mock_collection = double('Kitchen::Collection')

          allow(Kitchen::Config).to receive(:new).and_return(mock_config)
          allow(mock_config).to receive(:instances).and_return(mock_collection)
          allow(mock_collection).to receive(:get).and_return(mock_instance)
          allow(mock_instance).to receive(:test)
          allow(mock_collection).to receive(:each)

          runner.send(:test_box, md_rel)

          passed_dir = File.join(dir, 'builds', 'testing_passed', 'x86_64')
          passed_md  = File.join(passed_dir, md_rel)
          expect(File.exist?(passed_md)).to be true
          data = JSON.parse(File.read(passed_md))
          expect(data['providers'].length).to eq(1)
          expect(data['providers'].first['testing']).to eq('passed')
          # Build-complete metadata should be removed (only provider was tested)
          expect(File.exist?(File.join(build_complete_dir, md_rel))).to be false
        end
      end
    end

    it 'records a failing provider in the testing_failed metadata' do
      Dir.mktmpdir do |dir|
        md_rel = 'ubuntu-2404-x86_64._metadata.json'
        File.write(File.join(dir, md_rel), JSON.generate(md))

        build_complete_dir = File.join(dir, 'builds', 'build_complete')
        FileUtils.mkdir_p(build_complete_dir)
        File.write(File.join(build_complete_dir, 'ubuntu-2404-x86_64.virtualbox.box'), 'fake')

        Dir.chdir(dir) do
          mock_instance   = instance_double(Kitchen::Instance)
          mock_config     = instance_double(Kitchen::Config)
          mock_collection = double('Kitchen::Collection')

          allow(Kitchen::Config).to receive(:new).and_return(mock_config)
          allow(mock_config).to receive(:instances).and_return(mock_collection)
          allow(mock_collection).to receive(:get).and_return(mock_instance)
          allow(mock_instance).to receive(:test).and_raise(Kitchen::ActionFailed, 'something went wrong')
          allow(mock_collection).to receive(:each)

          runner.send(:test_box, md_rel)

          failed_dir = File.join(dir, 'builds', 'testing_failed', 'x86_64')
          failed_md  = File.join(failed_dir, md_rel)
          expect(File.exist?(failed_md)).to be true
          data = JSON.parse(File.read(failed_md))
          expect(data['providers'].length).to eq(1)
          expect(data['providers'].first['testing']).to include('failed')
          expect(runner.errors).to include('ubuntu-2404-x86_64.virtualbox.box')
          # Build-complete metadata should be removed (only provider was tested)
          expect(File.exist?(File.join(build_complete_dir, md_rel))).to be false
        end
      end
    end

    it 'removes the provider from the failed metadata when it subsequently passes' do
      Dir.mktmpdir do |dir|
        arch   = 'x86_64'
        md_rel = "ubuntu-2404-#{arch}._metadata.json"
        File.write(File.join(dir, md_rel), JSON.generate(md))

        build_complete_dir = File.join(dir, 'builds', 'build_complete')
        FileUtils.mkdir_p(build_complete_dir)
        File.write(File.join(build_complete_dir, "ubuntu-2404-#{arch}.virtualbox.box"), 'fake')

        # Pre-populate a failed metadata entry
        failed_dir = File.join(dir, 'builds', 'testing_failed', arch)
        FileUtils.mkdir_p(failed_dir)
        failed_md_path = File.join(failed_dir, md_rel)
        failed_md_data = md.merge('providers' => [{ 'name' => 'virtualbox', 'file' => "ubuntu-2404-#{arch}.virtualbox.box", 'testing' => 'failed: old error' }])
        File.write(failed_md_path, JSON.generate(failed_md_data))

        Dir.chdir(dir) do
          mock_instance   = instance_double(Kitchen::Instance)
          mock_config     = instance_double(Kitchen::Config)
          mock_collection = double('Kitchen::Collection')

          allow(Kitchen::Config).to receive(:new).and_return(mock_config)
          allow(mock_config).to receive(:instances).and_return(mock_collection)
          allow(mock_collection).to receive(:get).and_return(mock_instance)
          allow(mock_instance).to receive(:test)
          allow(mock_collection).to receive(:each)

          runner.send(:test_box, md_rel)

          # Failed metadata should be gone (provider list empty → file deleted)
          expect(File.exist?(failed_md_path)).to be false
        end
      end
    end
  end
end
