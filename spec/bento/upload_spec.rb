# frozen_string_literal: true

require 'bento/upload'

RSpec.describe UploadRunner do
  let(:opts) { build_opts(md_json: nil) }

  subject(:runner) { described_class.new(opts) }

  # ── helpers ────────────────────────────────────────────────────────────────

  describe '#box_desc' do
    it 'returns a description containing the box name with hyphens replaced by spaces' do
      expect(runner.box_desc('ubuntu-24.04')).to include('Ubuntu 24.04')
    end

    it 'capitalizes the first character of the formatted name' do
      desc = runner.box_desc('debian-12')
      expect(desc).to include('Debian 12')
    end
  end

  describe '#slug_desc' do
    it 'mentions the slug name in the description' do
      expect(runner.slug_desc('ubuntu-lts')).to include('Ubuntu lts')
    end

    it 'mentions the box will be updated with latest releases' do
      expect(runner.slug_desc('debian-latest')).to include('latest releases')
    end
  end

  describe '#ver_desc' do
    let(:md_data) do
      {
        'box_basename' => 'ubuntu-24.04-x86_64',
        'version' => '202506.01.0',
        'packer' => '1.9.0',
        'vagrant' => '2.4.1',
        'providers' => [
          { 'name' => 'virtualbox', 'version' => '7.1.0' },
          { 'name' => 'vmware_desktop', 'version' => '13.0' },
        ],
      }
    end

    it 'includes the box version' do
      expect(runner.ver_desc(md_data)).to include('202506.01.0')
    end

    it 'includes the packer version' do
      expect(runner.ver_desc(md_data)).to include('packer: 1.9.0')
    end

    it 'includes the vagrant version' do
      expect(runner.ver_desc(md_data)).to include('vagrant: 2.4.1')
    end

    it 'labels vmware_desktop as vmware-fusion on macOS' do
      allow(runner).to receive(:macos?).and_return(true)
      expect(runner.ver_desc(md_data)).to include('vmware-fusion')
    end

    it 'labels vmware_desktop as vmware-workstation on non-macOS' do
      allow(runner).to receive(:macos?).and_return(false)
      expect(runner.ver_desc(md_data)).to include('vmware-workstation')
    end
  end

  describe '#public_private_box' do
    let(:builds_data) { { 'public' => %w(ubuntu debian), 'vagrant_cloud_account' => 'bento', 'slugs' => [], 'default_architectures' => [] } }

    before { allow(runner).to receive(:builds_yml).and_return(builds_data) }

    it 'returns --no-private for a box with a public prefix' do
      expect(runner.public_private_box('ubuntu-24.04')).to eq('--no-private')
    end

    it 'returns --private for an unlisted box' do
      expect(runner.public_private_box('rhel-9')).to eq('--private')
    end
  end

  describe '#default_arch' do
    let(:builds_data) { { 'default_architectures' => ['amd64'], 'public' => [], 'slugs' => [], 'vagrant_cloud_account' => 'bento' } }

    before { allow(runner).to receive(:builds_yml).and_return(builds_data) }

    it 'returns --default-architecture when arch matches a default' do
      expect(runner.default_arch('amd64')).to eq('--default-architecture')
    end

    it 'returns --no-default-architecture when arch is not a default' do
      expect(runner.default_arch('arm64')).to eq('--no-default-architecture')
    end
  end

  describe '#lookup_slug' do
    let(:builds_data) do
      {
        'slugs' => %w(ubuntu debian-latest),
        'public' => [],
        'default_architectures' => [],
        'vagrant_cloud_account' => 'bento',
      }
    end

    before do
      allow(runner).to receive(:builds_yml).and_return(builds_data)
      allow(Dir).to receive(:glob).and_return([])
    end

    it 'returns the slug when box name starts with it' do
      expect(runner.lookup_slug('ubuntu-24.04')).to eq('ubuntu')
    end

    it 'returns nil when no slug matches' do
      allow(runner).to receive(:builds_yml).and_return(builds_data)
      allow(Dir).to receive(:glob).and_return([])
      expect(runner.lookup_slug('windows-2022')).to be_nil
    end
  end

  describe '#error_unless_logged_in' do
    it 'warns when not logged into vagrant cloud' do
      allow(runner).to receive(:logged_in?).and_return(false)
      expect { runner.error_unless_logged_in }.to output(/cannot upload/).to_stdout
    end

    it 'does nothing when logged in' do
      allow(runner).to receive(:logged_in?).and_return(true)
      expect { runner.error_unless_logged_in }.not_to output.to_stdout
    end
  end

  describe '#start' do
    it 'calls upload_box for each metadata file' do
      allow(runner).to receive(:error_unless_logged_in)
      allow(runner).to receive(:metadata_files).and_return(['a._metadata.json', 'b._metadata.json'])
      expect(runner).to receive(:upload_box).twice
      runner.start
    end

    it 'uses the specified md_json when provided' do
      r = described_class.new(build_opts(md_json: 'custom._metadata.json'))
      allow(r).to receive(:error_unless_logged_in)
      expect(r).to receive(:upload_box).with('custom._metadata.json')
      r.start
    end
  end
end
