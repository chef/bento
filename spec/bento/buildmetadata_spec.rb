# frozen_string_literal: true

require 'bento/buildmetadata'

RSpec.describe BuildMetadata do
  let(:template)          { 'ubuntu-24.04-x86_64' }
  let(:build_timestamp)   { '20260601120000' }
  let(:override_version)  { '202506.01.0' }
  let(:pkr_cmd)           { 'packer build ...' }

  let(:pkrvars_content) do
    <<~HCL
      os_name    = "ubuntu"
      os_version = "24.04"
      arch       = "x86_64"
      name       = "ubuntu"
    HCL
  end

  subject(:metadata) { described_class.new(template, build_timestamp, override_version, pkr_cmd) }

  before do
    allow(metadata).to receive(:git_revision).and_return('abc123')
    allow(metadata).to receive(:git_clean?).and_return(true)
    allow(metadata).to receive(:packer_ver).and_return('1.9.0')
    allow(metadata).to receive(:vagrant_ver).and_return('2.4.1')
  end

  describe '#read' do
    context 'with a valid pkrvars.hcl file' do
      around do |example|
        Dir.mktmpdir do |dir|
          Dir.chdir(dir) do
            File.write("#{template}.pkrvars.hcl", pkrvars_content)
            example.run
          end
        end
      end

      it 'returns a hash with all required keys' do
        result = metadata.read
        expect(result).to include(
          :name, :version, :arch, :build_timestamp, :packer_command,
          :git_revision, :git_status, :box_basename, :template, :packer, :vagrant
        )
      end

      it 'uses the override_version' do
        expect(metadata.read[:version]).to eq(override_version)
      end

      it 'sets git_status to clean when repo is clean' do
        expect(metadata.read[:git_status]).to eq('clean')
      end

      it 'sets git_status to dirty when repo has changes' do
        allow(metadata).to receive(:git_clean?).and_return(false)
        expect(metadata.read[:git_status]).to eq('dirty')
      end

      it 'sets the packer_command' do
        expect(metadata.read[:packer_command]).to eq(pkr_cmd)
      end

      it 'sets the build_timestamp' do
        expect(metadata.read[:build_timestamp]).to eq(build_timestamp)
      end

      it 'derives box_basename from name' do
        result = metadata.read
        expect(result[:box_basename]).to be_a(String)
        expect(result[:box_basename]).not_to be_empty
      end
    end

    context 'when override_version is nil' do
      subject(:metadata) { described_class.new(template, build_timestamp, nil, pkr_cmd) }

      around do |example|
        Dir.mktmpdir do |dir|
          Dir.chdir(dir) do
            File.write("#{template}.pkrvars.hcl", pkrvars_content)
            example.run
          end
        end
      end

      it 'falls back to a version derived from build_timestamp' do
        result = metadata.read
        expect(result[:version]).to include(build_timestamp)
      end
    end
  end

  describe 'box_basename' do
    around do |example|
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          File.write("#{template}.pkrvars.hcl", pkrvars_content)
          example.run
        end
      end
    end

    it 'replaces slashes with double underscores' do
      content = <<~HCL
        name       = "my/box"
        os_version = "1.0"
        arch       = "x86_64"
      HCL
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          t = 'my-box-x86_64'
          File.write("#{t}.pkrvars.hcl", content)
          m = described_class.new(t, build_timestamp, override_version, pkr_cmd)
          allow(m).to receive_messages(git_revision: 'abc', git_clean?: true, packer_ver: '1.9', vagrant_ver: '2.4')
          expect(m.read[:box_basename]).to include('__')
        end
      end
    end
  end
end
