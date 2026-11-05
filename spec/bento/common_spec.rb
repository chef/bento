# frozen_string_literal: true

require 'bento/common'

# Concrete class to mix the module into for testing
class CommonHost
  include Common
end

RSpec.describe Common do
  subject(:host) { CommonHost.new }

  describe '#banner' do
    it 'prints a banner-prefixed message to stdout' do
      expect { host.banner('hello') }.to output("==> hello\n").to_stdout
    end
  end

  describe '#info' do
    it 'prints an indented message to stdout' do
      expect { host.info('detail') }.to output("    detail\n").to_stdout
    end
  end

  describe '#warn' do
    it 'prints a warn-prefixed message to stdout' do
      expect { host.warn('caution') }.to output(">>> caution\n").to_stdout
    end
  end

  describe '#duration' do
    it 'formats seconds under a minute' do
      expect(host.duration(45.5)).to eq('0m45.50s')
    end

    it 'formats seconds spanning multiple minutes' do
      expect(host.duration(125.0)).to eq('2m5.00s')
    end

    it 'handles nil gracefully by treating it as zero' do
      expect(host.duration(nil)).to eq('0m0.00s')
    end
  end

  describe '#box_metadata' do
    it 'parses a JSON file into a hash' do
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'test._metadata.json')
        data = { 'name' => 'ubuntu-24.04', 'version' => '1.0' }
        File.write(path, JSON.generate(data))
        expect(host.box_metadata(path)).to eq(data)
      end
    end
  end

  describe '#metadata_files' do
    it 'globs build_complete directory for metadata files' do
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          FileUtils.mkdir_p('builds/build_complete')
          File.write('builds/build_complete/ubuntu-24.04-x86_64._metadata.json', '{}')
          File.write('builds/build_complete/other.txt', 'not json')
          files = host.metadata_files(false)
          expect(files.length).to eq(1)
          expect(files.first).to include('_metadata.json')
        end
      end
    end

    it 'globs testing_passed directory when upload flag is true' do
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          arch = RbConfig::CONFIG['host_cpu'] == 'arm64' ? 'aarch64' : RbConfig::CONFIG['host_cpu']
          FileUtils.mkdir_p("builds/testing_passed/#{arch}")
          File.write("builds/testing_passed/#{arch}/ubuntu-24.04-#{arch}._metadata.json", '{}')
          files = host.metadata_files(true, true)
          expect(files.length).to eq(1)
        end
      end
    end
  end

  describe '#builds_yml' do
    it 'parses builds.yml from the current directory' do
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          File.write('builds.yml', "vagrant_cloud_account: bento\npublic:\n  - ubuntu\n")
          result = host.builds_yml
          expect(result['vagrant_cloud_account']).to eq('bento')
          expect(result['public']).to include('ubuntu')
        end
      end
    end
  end

  describe '#apple_silicon?' do
    it 'returns true when host_cpu is arm64 or aarch64' do
      stub_const('RbConfig::CONFIG', RbConfig::CONFIG.merge('host_cpu' => 'arm64'))
      expect(host.apple_silicon?).to be true
      stub_const('RbConfig::CONFIG', RbConfig::CONFIG.merge('host_cpu' => 'aarch64'))
      expect(host.apple_silicon?).to be true
    end

    it 'returns false when host_cpu is x86_64' do
      stub_const('RbConfig::CONFIG', RbConfig::CONFIG.merge('host_cpu' => 'x86_64'))
      expect(host.apple_silicon?).to be false
    end
  end

  describe '#verify_macos_build_host!' do
    it 'returns true when running on macOS with Apple Silicon' do
      allow(host).to receive(:macos?).and_return(true)
      allow(host).to receive(:apple_silicon?).and_return(true)
      expect(host.verify_macos_build_host!).to be true
    end

    it 'raises RuntimeError if not running on macOS' do
      allow(host).to receive(:macos?).and_return(false)
      expect { host.verify_macos_build_host! }.to raise_error(/genuine Apple-branded hardware running macOS/)
    end

    it 'raises RuntimeError if running on macOS with non-ARM architecture' do
      allow(host).to receive(:macos?).and_return(true)
      allow(host).to receive(:apple_silicon?).and_return(false)
      expect { host.verify_macos_build_host! }.to raise_error(/requires Apple Silicon/)
    end
  end
end
