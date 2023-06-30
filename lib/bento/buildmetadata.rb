require 'bento/common'
require 'mixlib/shellout' unless defined?(Mixlib::ShellOut)

class BuildMetadata
  include Common

  def initialize(template, build_timestamp, override_version)
    @template = template
    @build_timestamp = build_timestamp
    @override_version = override_version
  end

  def read
    {
      name:             name,
      version:          version,
      arch:             arch,
      build_timestamp:  build_timestamp,
      git_revision:     git_revision,
      git_status:       git_clean? ? 'clean' : 'dirty',
      box_basename:     box_basename,
      template:         template_vars.fetch('template', UNKNOWN),
      packer:           packer_ver,
    }
  end

  private

  UNKNOWN = '__unknown__'.freeze

  attr_reader :template, :build_timestamp, :override_version

  def box_basename
    "#{name.gsub('/', '__')}"
  end

  def git_revision
    `git rev-parse HEAD`.strip
  end

  def git_clean?
    `git status --porcelain`.strip.empty?
  end

  def merged_vars
    @merged_vars ||= begin
      if File.exist?("#{template}.variables.json")
        template_vars.merge(JSON.load(IO.read("#{template}.variables.json")))
      else
        template_vars
      end
    end
  end

  def name
    arch = merged_vars.fetch('arch', UNKNOWN).downcase
    if arch == 'aarch64' || arch == 'arm64'
      "#{merged_vars.fetch('name', template)}-arm64"
    else
      "#{merged_vars.fetch('name', template)}-x86_64"
    end
  end

  def arch
    merged_vars.fetch('arch', UNKNOWN)
  end

  def template_vars
    @template_vars ||= begin
                         file_data = {}
                         File.open("#{template}.pkrvars.hcl", 'r') do |file|
                           file.each_line do |line|
                             line_data = line.split('=')
                             if line_data[0].strip.gsub(/"|os_/, '') == 'version'
                               file_data['name'] = "#{file_data['name']}-#{line_data[1]&.strip&.tr('"', '')}"
                             else
                               file_data[line_data[0]&.strip&.gsub(/"|os_/, '')] = line_data[1]&.strip&.tr('"', '')
                             end
                           end
                           file_data['template'] = "#{file_data['name']}-#{file_data['arch']}"
                         end
                         file_data
                       end
  end

  def version
    override_version || merged_vars.fetch('version', "#{UNKNOWN}.TIMESTAMP")
                                   .rpartition('.').first.concat(build_timestamp.to_s)
  end

  def packer_ver
    cmd = Mixlib::ShellOut.new('packer --version')
    cmd.run_command
    cmd.stdout.split("\n")[0]
  end
end
