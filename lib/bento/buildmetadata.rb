require "bento/common"
require "mixlib/shellout"

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
      build_timestamp:  build_timestamp,
      git_revision:     git_revision,
      git_status:       git_clean? ? "clean" : "dirty",
      box_basename:     box_basename,
      template:         template_vars.fetch("template", UNKNOWN),
      packer:           packer_ver,
      vagrant:          vagrant_ver,
    }
  end

  private

  UNKNOWN = "__unknown__".freeze

  attr_reader :template, :build_timestamp, :override_version

  def box_basename
    "#{name.gsub("/", "__")}-#{version}"
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
    merged_vars.fetch("name", template)
  end

  def template_vars
    @template_vars ||= JSON.load(IO.read("#{template}.json")).fetch("variables")
  end

  def version
    override_version || merged_vars.fetch("version", "#{UNKNOWN}.TIMESTAMP")
                                   .rpartition(".").first.concat(build_timestamp.to_s)
  end

  def packer_ver
    cmd = Mixlib::ShellOut.new("packer --version")
    cmd.run_command
    cmd.stdout.split("\n")[0]
  end

  def vagrant_ver
    if ENV["TRAVIS"]
      "travis"
    else
      cmd = Mixlib::ShellOut.new("vagrant --version")
      cmd.run_command
      cmd.stdout.split(" ")[1]
    end
  end
end
