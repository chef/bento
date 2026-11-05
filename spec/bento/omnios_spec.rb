# frozen_string_literal: true

#
# @file omnios_spec.rb
# @brief Unit tests verifying OmniOS CE build configuration, metadata, and packaging rules
# @description
#   Validates that OmniOS pkrvars files correctly parse into BuildMetadata structures,
#   that OmniOS is classified as a public open-source distribution without proprietary
#   restrictions, that slugs and public box prefixes resolve accurately from builds.yml,
#   and that unattended installation artifacts and Vagrant templates conform to requirements.
#

require 'spec_helper'
require 'bento/common'
require 'bento/buildmetadata'
require 'bento/upload'

#
# @class OmniosTestHost
# @description Test helper host class mixing in Common for isolated testing.
#
class OmniosTestHost
  include Common
end

RSpec.describe 'OmniOS Support' do
  let(:host) { OmniosTestHost.new }
  let(:upload_runner) { UploadRunner.new(OpenStruct.new(md_json: nil)) }

  describe 'BuildMetadata integration' do
    it 'correctly parses omnios-r151058-x86_64 pkrvars' do
      template_path = 'os_pkrvars/omnios/omnios-r151058-x86_64'
      bm = BuildMetadata.new(template_path, '20260915120000', '202609.15.0', 'packer build')
      data = bm.read

      expect(data[:name]).to eq('omnios-r151058')
      expect(data[:arch]).to eq('x86_64')
      expect(data[:box_basename]).to eq('omnios-r151058')
      expect(data[:template]).to eq('omnios-r151058-x86_64')
      expect(data[:version]).to eq('202609.15.0')
    end

    it 'correctly parses omnios-r151054-x86_64 pkrvars' do
      template_path = 'os_pkrvars/omnios/omnios-r151054-x86_64'
      bm = BuildMetadata.new(template_path, '20260915120000', '202609.15.0', 'packer build')
      data = bm.read

      expect(data[:name]).to eq('omnios-r151054')
      expect(data[:arch]).to eq('x86_64')
      expect(data[:box_basename]).to eq('omnios-r151054')
      expect(data[:template]).to eq('omnios-r151054-x86_64')
    end

    it 'correctly parses omnios-braich-aarch64 pkrvars' do
      template_path = 'os_pkrvars/omnios/omnios-braich-aarch64'
      bm = BuildMetadata.new(template_path, '20260915120000', '202609.15.0', 'packer build')
      data = bm.read

      expect(data[:name]).to eq('omnios-braich')
      expect(data[:arch]).to eq('aarch64')
      expect(data[:box_basename]).to eq('omnios-braich')
      expect(data[:template]).to eq('omnios-braich-aarch64')
    end
  end

  describe 'Distribution licensing classification' do
    it 'classifies omnios as non-proprietary public boxes' do
      expect(host.private_box?('omnios-r151058-x86_64')).to be false
      expect(host.private_box?('omnios-r151054-x86_64')).to be false
      expect(host.private_box?('omnios-braich-aarch64')).to be false
    end
  end

  describe 'builds.yml orchestration metadata' do
    it 'lists omnios releases under public distribution targets' do
      config = host.builds_yml
      expect(config['public']).to include('omnios-r151058')
      expect(config['public']).to include('omnios-r151054')
      expect(config['public']).to include('omnios-braich')
    end

    it 'defines slugs for standard omnios release lines' do
      config = host.builds_yml
      expect(config['slugs']).to include('omnios-r151058')
      expect(config['slugs']).to include('omnios-r151054')
    end

    it 'resolves slugs and publication visibility in UploadRunner' do
      expect(upload_runner.lookup_slug('omnios-r151058-x86_64')).to eq('omnios-r151058')
      expect(upload_runner.lookup_slug('omnios-r151054-x86_64')).to eq('omnios-r151054')
      expect(upload_runner.public_private_box('omnios-r151058')).to eq('--no-private')
      expect(upload_runner.public_private_box('omnios-r151054')).to eq('--no-private')
      expect(upload_runner.public_private_box('omnios-braich')).to eq('--no-private')
    end
  end

  describe 'Vagrant templates and unattended manifests' do
    it 'provides a valid vagrantfile template for omnios' do
      template = File.read('packer_templates/vagrantfile-omnios.template')
      expect(template).to include('config.vm.guest = :solaris')
      expect(template).to include('config.vm.synced_folder ".", "/vagrant", type: "rsync"')
    end

    it 'provides a valid kayak installer configuration' do
      kayak_cfg = File.read('packer_templates/http/omnios/kayak.cfg')
      expect(kayak_cfg).to include('BuildRpool')
      expect(kayak_cfg).to include('SetHostname omnios-bento')
      expect(kayak_cfg).to include('SetDNS 1.1.1.1 8.8.8.8')
      expect(kayak_cfg).to include('Postboot')
    end
  end
end
