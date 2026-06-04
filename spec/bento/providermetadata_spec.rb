# frozen_string_literal: true

require 'bento/providermetadata'

RSpec.describe ProviderMetadata do
  let(:tmpdir) { Dir.mktmpdir }
  let(:box_basename) { 'ubuntu-24.04-x86_64' }

  subject(:provider_meta) { described_class.new(tmpdir, box_basename) }

  after { FileUtils.rm_rf(tmpdir) }

  describe '#read' do
    context 'with no box files present' do
      it 'returns an empty array' do
        expect(provider_meta.read).to eq([])
      end
    end

    context 'with a single virtualbox box file' do
      let(:box_file) { File.join(tmpdir, "#{box_basename}.virtualbox.box") }

      before do
        File.write(box_file, 'fake box content')
        allow(provider_meta).to receive(:version).with('virtualbox').and_return('7.1.0')
      end

      it 'returns one provider entry' do
        result = provider_meta.read
        expect(result.length).to eq(1)
      end

      it 'sets the provider name to virtualbox' do
        expect(provider_meta.read.first[:name]).to eq('virtualbox')
      end

      it 'sets the file to just the basename' do
        expect(provider_meta.read.first[:file]).to eq(File.basename(box_file))
      end

      it 'sets checksum_type to sha256' do
        expect(provider_meta.read.first[:checksum_type]).to eq('sha256')
      end

      it 'calculates a sha256 checksum' do
        result = provider_meta.read.first
        expected = Digest::SHA256.file(box_file).hexdigest
        expect(result[:checksum]).to eq(expected)
      end

      it 'reports size in MB' do
        expect(provider_meta.read.first[:size]).to match(/\d+ MB/)
      end
    end

    context 'with a vmware box file' do
      let(:box_file) { File.join(tmpdir, "#{box_basename}.vmware.box") }

      before do
        File.write(box_file, 'fake vmware box')
        allow(provider_meta).to receive(:version).with('vmware_desktop').and_return('13.0')
      end

      it 'maps vmware to vmware_desktop provider name' do
        result = provider_meta.read
        expect(result.first[:name]).to eq('vmware_desktop')
      end
    end

    context 'with a libvirt box file' do
      let(:libvirt_file) { File.join(tmpdir, "#{box_basename}.libvirt.box") }

      before do
        File.write(libvirt_file, 'fake libvirt box')
        allow(provider_meta).to receive(:version).and_return('9.0')
      end

      it 'copies libvirt box to a qemu box' do
        provider_meta.read
        expect(File.exist?(File.join(tmpdir, "#{box_basename}.qemu.box"))).to be true
      end

      it 'includes both libvirt and qemu in providers' do
        result = provider_meta.read
        names = result.map { |p| p[:name] }
        expect(names).to include('libvirt', 'qemu')
      end
    end
  end

  describe 'provider_from_file (via read)' do
    it 'extracts the provider name between the last two dots' do
      File.write(File.join(tmpdir, "#{box_basename}.parallels.box"), 'x')
      allow(provider_meta).to receive(:version).and_return('20.0')
      result = provider_meta.read
      expect(result.first[:name]).to eq('parallels')
    end
  end
end
