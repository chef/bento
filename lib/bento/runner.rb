require "bento/common"
require "bento/buildmetadata"
require "bento/providermetadata"
require "bento/packerexec"

class BuildRunner
  include Common
  include PackerExec

  attr_reader :template_files, :config, :dry_run, :debug, :only, :except, :mirror, :headed, :single,
              :override_version, :build_timestamp, :cpus, :mem

  def initialize(opts)
    @template_files = opts.template_files
    @config = opts.config ||= false
    @dry_run = opts.dry_run
    @debug = opts.debug
    @only = opts.only ||= "parallels-iso,virtualbox-iso,vmware-iso"
    @except = opts.except
    @mirror = opts.mirror
    @headed = opts.headed ||= false
    @single = opts.single ||= false
    @override_version = opts.override_version
    @build_timestamp = Time.now.gmtime.strftime("%Y%m%d%H%M%S")
    @cpus = opts.cpus
    @mem = opts.mem
  end

  def start
    templates = config ? build_list : template_files
    banner("Starting build for templates:")
    templates.each { |t| puts "- #{t}" }
    time = Benchmark.measure do
      templates.each { |template| build(template) }
    end
    banner("Build finished in #{duration(time.real)}.")
  end

  private

  def build(file)
    bento_dir = Dir.pwd
    dir = File.dirname(file)
    template = File.basename(file)
    Dir.chdir dir
    for_packer_run_with(template) do |md_file, _var_file|
      cmd = packer_build_cmd(template, md_file.path)
      banner("[#{template}] Building: '#{cmd.join(' ')}'")
      time = Benchmark.measure do
        system(*cmd) || raise("[#{template}] Error building, exited #{$CHILD_STATUS}")
      end
      write_final_metadata(template, time.real.ceil)
      banner("[#{template}] Finished building in #{duration(time.real)}.")
    end
    Dir.chdir(bento_dir)
  end

  def packer_build_cmd(template, var_file)
    vars = "#{template}.variables.json"
    cmd = %W{packer build -force -var-file=#{var_file} #{template}.json}
    cmd.insert(2, "-var-file=#{vars}") if File.exist?(vars)
    cmd.insert(2, "-only=#{only}")
    cmd.insert(2, "-except=#{except}") if except
    # Build the command line in the correct order and without spaces as future input for the splat operator.
    cmd.insert(2, "cpus=#{cpus}") if cpus
    cmd.insert(2, "-var") if cpus
    cmd.insert(2, "memory=#{mem}") if mem
    cmd.insert(2, "-var") if mem
    cmd.insert(2, "mirror=#{mirror}") if mirror
    cmd.insert(2, "-var") if mirror
    cmd.insert(2, "headless=true") unless headed
    cmd.insert(2, "-var") unless headed
    cmd.insert(2, "-parallel=false") if single
    cmd.insert(2, "-debug") if debug
    cmd.insert(0, "echo") if dry_run
    cmd
  end

  def write_final_metadata(template, buildtime)
    md = BuildMetadata.new(template, build_timestamp, override_version).read
    path = File.join("../../builds")
    filename = File.join(path, "#{md[:box_basename]}.metadata.json")
    md[:providers] = ProviderMetadata.new(path, md[:box_basename]).read
    md[:providers].each do |p|
      p[:build_time] = buildtime
      p[:build_cpus] = cpus unless cpus.nil?
      p[:build_mem] = mem unless mem.nil?
    end

    if dry_run
      banner("(Dry run) Metadata file contents would be something similar to:")
      puts JSON.pretty_generate(md)
    else
      File.open(filename, "wb") { |file| file.write(JSON.pretty_generate(md)) }
    end
  end
end
