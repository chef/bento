require 'bento/common'
require 'bento/buildmetadata'
require 'bento/providermetadata'
require 'bento/packerexec'
require 'mixlib/shellout' unless defined?(Mixlib::ShellOut)

class BuildRunner
  include Common
  include PackerExec

  attr_reader :template_files, :config, :dry_run, :debug, :only, :except, :mirror, :headed, :single, :errors,
              :override_version, :build_timestamp, :cpus, :mem, :metadata_only, :vars, :var_files, :pkr_cmd

  def initialize(opts)
    @template_files = opts.template_files
    @config = opts.config ||= false
    @dry_run = opts.dry_run
    @metadata_only = opts.metadata_only
    @debug = opts.debug
    @only = opts.only ||= nil
    @except = opts.except
    @mirror = opts.mirror
    @headed = opts.headed ||= false
    @single = opts.single ||= false
    @override_version = opts.override_version
    @build_timestamp = Time.now.gmtime.strftime('%Y%m%d%H%M%S')
    @cpus = opts.cpus
    @mem = opts.mem
    @vars = opts.vars&.split(',')
    @var_files = opts.var_files&.split(',')
    @errors = []
    @pkr_cmd = nil
  end

  def start
    templates = config ? build_list : template_files
    banner('Starting build for templates:')
    banner('Installing packer plugins') unless dry_run || metadata_only
    shellout("packer init -upgrade #{File.dirname(templates.first)}/../../packer_templates") unless dry_run || metadata_only
    templates.each { |t| puts "- #{t}" }
    time = Benchmark.measure do
      templates.each { |template| build(template) }
    end
    banner("Build finished in #{duration(time.real)}.")
    unless errors.empty?
      raise("Failed Builds:\n #{errors.join("\n")}\n exited #{$CHILD_STATUS}")
    end
  end

  private

  def build(file)
    bento_dir = Dir.pwd
    dir = File.dirname(file)
    template = File.basename(file)
    cmd = nil
    Dir.chdir dir
    for_packer_run_with(template) do |md_file, _var_file|
      cmd = Mixlib::ShellOut.new(packer_build_cmd(template, md_file.path).join(' '))
      cmd.live_stream = STDOUT
      cmd.timeout = 28800
      @pkr_cmd = cmd.command
      banner("[#{template}] Building: '#{cmd.command}'")
      time = Benchmark.measure do
        cmd.run_command
      end
      if Dir.glob("../../builds/#{template.split('-')[0...-1].join('-')}*-#{template.split('-')[-1]}.*.box").empty?
        banner('Not writing metadata file since no boxes exist')
      else
        write_final_metadata(template, time.real.ceil)
      end
      banner("[#{template}] Finished building in #{duration(time.real)}.")
    end
    Dir.chdir(bento_dir)
    if cmd.error?
      cmd.stderr
      errors << template
    end
  end

  def packer_build_cmd(template, _var_file)
    pkrvars = "#{template}.pkrvars.hcl"
    cmd = %W(packer build -timestamp-ui -force -var-file=#{pkrvars} ../../packer_templates)
    vars.each do |var|
      cmd.insert(4, "-var #{var}")
    end if vars
    var_files.each do |var_file|
      cmd.insert(5, "-var-file=#{var_file}") if File.exist?(var_file)
    end if var_files
    cmd.insert(4, "-only=#{only}") if only
    cmd.insert(4, "-except=#{except}") if except
    # Build the command line in the correct order and without spaces as future input for the splat operator.
    cmd.insert(4, "-var cpus=#{cpus}") if cpus
    cmd.insert(4, "-var memory=#{mem}") if mem
    cmd.insert(4, '-var headless=false') if headed
    cmd.insert(2, '-parallel=false') if single
    cmd.insert(2, '-debug') if debug
    cmd.insert(0, 'echo') if dry_run || metadata_only
    cmd
  end

  def write_final_metadata(template, buildtime)
    md = BuildMetadata.new(template, build_timestamp, override_version, pkr_cmd).read
    path = File.join('../../builds')
    filename = File.join(path, "#{md[:template]}._metadata.json")
    md[:providers] = ProviderMetadata.new(path, md[:template]).read
    md[:providers].each do |p|
      p[:build_time] = buildtime
      p[:build_cpus] = cpus unless cpus.nil?
      p[:build_mem] = mem unless mem.nil?
    end

    if dry_run
      banner("(Dry run) Metadata file would be written to #{filename} with content similar to:")
      puts JSON.pretty_generate(md)
    else
      File.binwrite(filename, JSON.pretty_generate(md))
    end
  end
end
