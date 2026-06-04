# frozen_string_literal: true

require 'bento/packerexec'
require 'bento/buildmetadata'
require 'bento/common'

class PackerExecHost
  include Common
  include PackerExec

  attr_reader :build_timestamp, :override_version, :pkr_cmd

  def initialize
    @build_timestamp  = '20260601120000'
    @override_version = '202506.01.0'
    @pkr_cmd          = nil
  end
end

RSpec.describe PackerExec do
  subject(:host) { PackerExecHost.new }

  let(:template) { 'ubuntu-24.04-x86_64' }

  let(:pkrvars_content) do
    <<~HCL
      os_name    = "ubuntu"
      os_version = "24.04"
      arch       = "x86_64"
      name       = "ubuntu"
    HCL
  end

  before do
    # Stub external tool calls used by BuildMetadata
    allow_any_instance_of(BuildMetadata).to receive(:git_revision).and_return('deadbeef')
    allow_any_instance_of(BuildMetadata).to receive(:git_clean?).and_return(true)
    allow_any_instance_of(BuildMetadata).to receive(:packer_ver).and_return('1.9.0')
    allow_any_instance_of(BuildMetadata).to receive(:vagrant_ver).and_return('2.4.1')
  end

  describe '#for_packer_run_with' do
    it 'yields two Tempfile objects' do
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          File.write("#{template}.pkrvars.hcl", pkrvars_content)
          host.for_packer_run_with(template) do |md_file, var_file|
            expect(md_file).to respond_to(:path)
            expect(var_file).to respond_to(:path)
          end
        end
      end
    end
  end

  describe '#write_box_metadata' do
    it 'writes valid JSON to the file path' do
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          File.write("#{template}.pkrvars.hcl", pkrvars_content)
          Tempfile.open('test-md') do |f|
            path = f.path
            host.write_box_metadata(template, f)
            # write_box_metadata closes the file; read via path
            data = JSON.parse(File.read(path))
            expect(data).to include('name', 'version', 'arch')
          end
        end
      end
    end
  end

  describe '#write_var_file' do
    it 'writes valid JSON with box_basename and version' do
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          File.write("#{template}.pkrvars.hcl", pkrvars_content)
          Tempfile.open('test-md') do |md_file|
            host.write_box_metadata(template, md_file)
            md_file.path
            Tempfile.open('test-var') do |var_file|
              var_path = var_file.path
              host.write_var_file(template, md_file, var_file)
              data = JSON.parse(File.read(var_path))
              expect(data).to include('box_basename', 'version', 'build_timestamp', 'git_revision', 'metadata')
            end
          end
        end
      end
    end
  end
end
