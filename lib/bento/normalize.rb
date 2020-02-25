require "bento/common"

class NormalizeRunner
  include Common
  include PackerExec

  attr_reader :templates, :build_timestamp, :debug, :override_version

  def initialize(opts)
    @templates = opts.template_files
    @debug = opts.debug
    @modified = []
    @build_timestamp = Time.now.gmtime.strftime("%Y%m%d%H%M%S")
  end

  def start
    banner("Normalizing for templates:")
    templates.each { |t| puts "- #{t}" }
    time = Benchmark.measure do
      templates.each do |file|
        bento_dir = Dir.pwd
        dir = File.dirname(file)
        template = File.basename(file)
        Dir.chdir dir
        validate(template)
        Dir.chdir(bento_dir)
      end
    end
    unless @modified.empty?
      info("")
      info("The following templates were modified:")
      @modified.sort.each { |template| info("  * #{template}") }
    end
    banner("Normalizing finished in #{duration(time.real)}.")
  end

  private

  def checksum(file)
    Digest::MD5.file(file).hexdigest
  end

  def fix(template)
    file = "#{template}.json"

    banner("[#{template}] Fixing")
    original_checksum = checksum(file)
    output = `packer fix #{file}`
    raise "[#{template}] Error fixing, exited #{$CHILD_STATUS}" if $CHILD_STATUS.exitstatus != 0

    # preserve ampersands in shell commands,
    # see: https://github.com/mitchellh/packer/issues/784
    output.gsub!("\\u0026", "&")
    File.open(file, "wb") { |dest| dest.write(output) }
    fixed_checksum = checksum(file)

    if original_checksum == fixed_checksum
      puts("No changes made.")
    else
      warn("Template #{template} has been modified.")
      @modified << template
    end
  end

  def packer_validate_cmd(template, var_file)
    vars = "#{template}.variables.json"
    cmd = %W{packer validate -var-file=#{var_file} #{template}.json}
    cmd.insert(2, "-var-file=#{vars}") if File.exist?(vars)
    cmd
  end

  def validate(template)
    for_packer_run_with(template) do |md_file, var_file|
      cmd = packer_validate_cmd(template, var_file.path)
      banner("[#{template}] Validating: '#{cmd.join(' ')}'")
      if debug
        banner("[#{template}] DEBUG: var_file(#{var_file.path}) is:")
        puts IO.read(var_file.path)
        banner("[#{template}] DEBUG: md_file(#{md_file.path}) is:")
        puts IO.read(md_file.path)
      end
      system(*cmd) || raise("[#{template}] Error validating, exited #{$CHILD_STATUS}")
    end
  end
end
