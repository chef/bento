# frozen_string_literal: true

require 'bento/runner'

RSpec.describe BuildRunner do
  let(:template_file) { 'os_pkrvars/ubuntu/ubuntu-24.04-x86_64' }
  let(:opts) { build_opts(template_files: [template_file], override_version: '202506.01.0') }

  subject(:runner) { described_class.new(opts) }

  describe '#initialize' do
    it 'stores template_files' do
      expect(runner.template_files).to eq([template_file])
    end

    it 'starts with empty errors' do
      expect(runner.errors).to be_empty
    end

    it 'generates a build_timestamp at construction time' do
      expect(runner.build_timestamp).to match(/\A\d{14}\z/)
    end

    it 'splits vars string into an array' do
      r = described_class.new(build_opts(template_files: [], vars: 'boot_wait="2s",ssh_timeout="5s"'))
      expect(r.vars).to eq(['boot_wait="2s"', 'ssh_timeout="5s"'])
    end

    it 'splits var_files string into an array' do
      r = described_class.new(build_opts(template_files: [], var_files: '/a/b.hcl,/c/d.hcl'))
      expect(r.var_files).to eq(['/a/b.hcl', '/c/d.hcl'])
    end

    it 'defaults vars to nil when not provided' do
      expect(runner.vars).to be_nil
    end
  end

  describe '#packer_build_cmd (private)' do
    subject { runner.send(:packer_build_cmd, template_file, nil) }

    it 'includes packer build' do
      expect(subject.first).to eq('packer')
      expect(subject).to include('build')
    end

    it 'includes the -force flag' do
      expect(subject).to include('-force')
    end

    it 'prepends echo for dry runs' do
      r = described_class.new(build_opts(template_files: [template_file], dry_run: true))
      expect(r.send(:packer_build_cmd, template_file, nil).first).to eq('echo')
    end

    it 'prepends echo for metadata_only' do
      r = described_class.new(build_opts(template_files: [template_file], metadata_only: true))
      expect(r.send(:packer_build_cmd, template_file, nil).first).to eq('echo')
    end

    it 'inserts -only when provided' do
      r = described_class.new(build_opts(template_files: [template_file], only: 'virtualbox-iso.vm'))
      cmd = r.send(:packer_build_cmd, template_file, nil)
      expect(cmd.join(' ')).to include('-only=virtualbox-iso.vm')
    end

    it 'inserts -except when provided' do
      r = described_class.new(build_opts(template_files: [template_file], except: 'parallels-iso'))
      cmd = r.send(:packer_build_cmd, template_file, nil)
      expect(cmd.join(' ')).to include('-except=parallels-iso')
    end

    it 'inserts -debug when debug flag is set' do
      r = described_class.new(build_opts(template_files: [template_file], debug: true))
      expect(r.send(:packer_build_cmd, template_file, nil)).to include('-debug')
    end

    it 'inserts -parallel=false when single is set' do
      r = described_class.new(build_opts(template_files: [template_file], single: true))
      expect(r.send(:packer_build_cmd, template_file, nil)).to include('-parallel=false')
    end

    it 'inserts cpus var when specified' do
      r = described_class.new(build_opts(template_files: [template_file], cpus: '4'))
      expect(r.send(:packer_build_cmd, template_file, nil).join(' ')).to include('-var cpus=4')
    end

    it 'inserts memory var when specified' do
      r = described_class.new(build_opts(template_files: [template_file], mem: '4096'))
      expect(r.send(:packer_build_cmd, template_file, nil).join(' ')).to include('-var memory=4096')
    end

    it 'inserts headless=false when headed flag is set' do
      r = described_class.new(build_opts(template_files: [template_file], headed: true))
      expect(r.send(:packer_build_cmd, template_file, nil).join(' ')).to include('-var headless=false')
    end
  end

  describe '#start' do
    it 'raises with failed templates when builds fail' do
      allow(runner).to receive(:shellout)
      allow(runner).to receive(:build) { runner.errors << template_file }
      expect { runner.start }.to raise_error(RuntimeError, /Failed Builds/)
    end

    it 'completes without raising when all builds succeed' do
      allow(runner).to receive(:shellout)
      allow(runner).to receive(:build)
      expect { runner.start }.not_to raise_error
    end
  end
end
