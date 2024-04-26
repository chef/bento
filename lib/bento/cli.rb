require 'optparse' unless defined?(OptionParser)
require 'ostruct' unless defined?(OpenStruct)

require 'bento/common'
require 'bento/runner'
require 'bento/normalize'
require 'bento/test'
require 'bento/upload'
require 'bento/version'

class Options
  NAME = File.basename($PROGRAM_NAME).freeze

  def self.parse(args)
    arch = if RbConfig::CONFIG['host_cpu'] == 'arm64'
             'aarch64'
           else
             RbConfig::CONFIG['host_cpu']
           end
    not_buildable = YAML.load(File.read('builds.yml'))['do_not_build']
    options = OpenStruct.new
    options.template_files = calculate_templates("os_pkrvars/**/*-#{arch}.pkrvars.hcl")
    not_buildable.each do |os|
      options.template_files.delete_if { |template| template.include?(os) }
    end

    global = OptionParser.new do |opts|
      opts.banner = "Usage: #{NAME} [SUBCOMMAND [options]]"
      opts.separator ''
      opts.separator <<-COMMANDS.gsub(/^ {8}/, '')
        build        :   build one or more templates
        help         :   prints this help message
        list         :   list all templates in project
        normalize    :   normalize one or more templates
        test         :   test one or more builds with kitchen
        upload       :   upload and release one or more builds to Vagrant Cloud
        version      :   prints the version of #{NAME}
      COMMANDS
    end

    templates_argv_proc = proc { |opts|
      opts.template_files = calculate_templates(args) unless args.empty?

      opts.template_files.each do |t|
        unless File.exist?("#{t}.pkrvars.hcl")
          warn "File #{t}.pkrvars.hcl does not exist for template '#{t}'"
          exit(1)
        end
      end
    }

    test_argv_proc = proc { |opts|
      opts.regx = ARGV[0]
    }

    md_json_argv_proc = proc { |opts|
      opts.md_json = ARGV[0]
    }

    subcommand = {
      help: {
        parser: OptionParser.new {},
        argv: proc { |_opts|
          puts global
          exit(0)
        },
      },
      version: {
        parser: OptionParser.new {},
        argv: proc { |_opts|
          puts Bento::VERSION
          exit(0)
        },
      },
      build: {
        class: BuildRunner,
        parser: OptionParser.new do |opts|
          opts.banner = "Usage: #{NAME} build [options] TEMPLATE[ TEMPLATE ...]"

          opts.on('-n', '--dry-run', 'Dry run (what would happen)') do |opt|
            options.dry_run = opt
          end

          opts.on('--metadata_only', 'Only generate the metadata json file') do |opt|
            options.metadata_only = opt
          end

          opts.on('--on-error OPT', '[cleanup|abort|ask|run-cleanup-provisioner] If the build fails do: clean up (default), abort, ask, or run-cleanup-provisioner.') do |opt|
            options.on_error = opt
          end

          opts.on('--vars VARS', 'Comma seperated list of variable names equal values (ex: boot_wait="2s",ssh_timeout="5s")') do |opt|
            options.vars = opt
          end

          opts.on('--var_files VAR_FILES', 'Comma seperated list of pkrvar.hcl files to include in the builds (ex: /path/to/var_file.pkrvars.hcl,/path/to/next/var_file2.pkrvars.hcl)') do |opt|
            options.var_files = opt
          end

          opts.on('-d', '--[no-]debug', 'Run packer with debug output') do |opt|
            options.debug = opt
          end

          opts.on('-o BUILDS', '--only BUILDS', 'Only build some Packer builds (ex: parallels-iso.vm,virtualbox-iso.vm,vmware-iso.vm)') do |opt|
            options.only = opt
          end

          opts.on('-e BUILDS', '--except BUILDS', 'Build all Packer builds except these (ex: parallels-iso,virtualbox-iso,vmware-iso)') do |opt|
            options.except = opt
          end

          opts.on('-M MIRROR', '--mirror MIRROR', 'Look for isos at MIRROR') do |opt|
            options.mirror = opt
          end

          opts.on('-c CPUS', '--cpus CPUS', '# of CPUs per provider') do |opt|
            options.cpus = opt
          end

          opts.on('-m MEMORY', '--memory MEMORY', 'Memory (MB) per provider') do |opt|
            options.mem = opt
          end

          opts.on('-g', '--gui', 'Display provider GUI windows') do |opt|
            options.headed = opt
          end

          opts.on('-s', '--single', 'Disable parallelization of Packer builds') do |opt|
            options.single = opt
          end

          # the default template override version unless a user passes one
          options.override_version = Time.now.gmtime.strftime('%Y%m.%d.0')

          opts.on('-v VERSION', '--version VERSION', "Override the date computed version of #{options.override_version}") do |opt|
            options.override_version = opt
          end
        end,
        argv: templates_argv_proc,
      },
      list: {
        class: ListRunner,
        parser: OptionParser.new do |opts|
          opts.banner = "Usage: #{NAME} list [TEMPLATE ...]"
        end,
        argv: templates_argv_proc,
      },
      normalize: {
        class: NormalizeRunner,
        parser: OptionParser.new do |opts|
          opts.banner = "Usage: #{NAME} normalize TEMPLATE[ TEMPLATE ...]"

          opts.on('-d', '--[no-]debug', 'Run packer with debug output') do |opt|
            options.debug = opt
          end
        end,
        argv: templates_argv_proc,
      },
      test: {
        class: TestRunner,
        parser: OptionParser.new do |opts|
          opts.banner = "Usage: #{NAME} test [options]"

          opts.on('--no-shared-folder', 'Disable shared folder testing') do |opt|
            options.no_shared = opt
          end

          opts.on('-p', '--provisioner PROVISIONER', 'Use a specfic provisioner') do |opt|
            options.provisioner = opt
          end
        end,
        argv: test_argv_proc,
      },
      upload: {
        class: UploadRunner,
        parser: OptionParser.new do |opts|
          opts.banner = "Usage: #{NAME} upload"
        end,
        argv: md_json_argv_proc,
      },
    }

    global.order!
    command = args.empty? ? :help : ARGV.shift.to_sym
    subcommand.fetch(command).fetch(:parser).order!
    subcommand.fetch(command).fetch(:argv).call(options)

    options.command = command
    options.klass = subcommand.fetch(command).fetch(:class)

    options
  end

  def self.calculate_templates(globs)
    templates = Array(globs).map do |glob|
      result = Dir.glob(glob)
      result.empty? ? glob : result
    end
    templates.flatten.sort.delete_if { |file| file =~ /\.(variables||metadata)\.json/ }.map { |template| template.sub(/\.pkrvars\.hcl$/, '') }
  end
end

class ListRunner
  include Common

  attr_reader :templates

  def initialize(opts)
    @templates = opts.template_files
  end

  def start
    puts templates.join("\n")
  end
end

class Runner
  attr_reader :options

  def initialize(options)
    @options = options
  end

  def start
    options.klass.new(options).start
  end
end
