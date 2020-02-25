require "optparse"
require "ostruct"

require "bento/common"
require "bento/runner"
require "bento/normalize"
require "bento/test"
require "bento/upload"

class Options
  NAME = File.basename($PROGRAM_NAME).freeze

  def self.parse(args)
    options = OpenStruct.new
    options.template_files = calculate_templates("packer_templates/**/*.json")

    global = OptionParser.new do |opts|
      opts.banner = "Usage: #{NAME} [SUBCOMMAND [options]]"
      opts.separator ""
      opts.separator <<-COMMANDS.gsub(/^ {8}/, "")
        build        :   build one or more templates
        help         :   prints this help message
        list         :   list all templates in project
        normalize    :   normalize one or more templates
        test         :   test one or more builds with kitchen
        upload       :   upload and release one or more builds to Vagrant Cloud
      COMMANDS
    end

    # @tas50: commenting this out since it's unused 11/30/2018
    # platforms_argv_proc = proc { |opts|
    #   opts.platforms = builds["public"] unless args.empty?
    # }

    templates_argv_proc = proc { |opts|
      opts.template_files = calculate_templates(args) unless args.empty?

      opts.template_files.each do |t|
        unless File.exist?("#{t}.json")
          warn "File #{t}.json does not exist for template '#{t}'"
          exit(1)
        end
      end
    }

    box_version_argv_proc = proc { |opts|
      opts.box = ARGV[0]
      opts.version = ARGV[1]
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
      build: {
        class: BuildRunner,
        parser: OptionParser.new do |opts|
          opts.banner = "Usage: #{NAME} build [options] TEMPLATE[ TEMPLATE ...]"

          opts.on("-n", "--dry-run", "Dry run (what would happen)") do |opt|
            options.dry_run = opt
          end

          opts.on("-c BUILD_YML", "--config BUILD_YML", "Use a configuration file") do |opt|
            options.config = opt
          end

          opts.on("-d", "--[no-]debug", "Run packer with debug output") do |opt|
            options.debug = opt
          end

          opts.on("-o BUILDS", "--only BUILDS", "Only build some Packer builds (ex: parallels-iso,virtualbox-iso,vmware-iso)") do |opt|
            options.only = opt
          end

          opts.on("-e BUILDS", "--except BUILDS", "Build all Packer builds except these (ex: parallels-iso,virtualbox-iso,vmware-iso)") do |opt|
            options.except = opt
          end

          opts.on("-m MIRROR", "--mirror MIRROR", "Look for isos at MIRROR") do |opt|
            options.mirror = opt
          end

          opts.on("-C cpus", "--cpus CPUS", "# of CPUs per provider") do |opt|
            options.cpus = opt
          end

          opts.on("-M MEMORY", "--memory MEMORY", "Memory (MB) per provider") do |opt|
            options.mem = opt
          end

          opts.on("-H", "--headed", "Display provider UI windows") do |opt|
            options.headed = opt
          end

          opts.on("-S", "--single", "Disable parallelization of Packer builds") do |opt|
            options.single = opt
          end

          # the default template override version unless a user passes one
          options.override_version = Time.now.gmtime.strftime("%Y%m.%d.0")

          opts.on("-v VERSION", "--version VERSION", "Override the date computed version of #{options.override_version}") do |opt|
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

          opts.on("-d", "--[no-]debug", "Run packer with debug output") do |opt|
            options.debug = opt
          end
        end,
        argv: templates_argv_proc,
      },
      test: {
        class: TestRunner,
        parser: OptionParser.new do |opts|
          opts.banner = "Usage: #{NAME} test [options]"

          opts.on("--no-shared-folder", "Disable shared folder testing") do |opt|
            options.no_shared = opt
          end

          opts.on("-p", "--provisioner PROVISIONER", "Use a specfic provisioner") do |opt|
            options.provisioner = opt
          end
        end,
        argv: proc {},
      },
      upload: {
        class: UploadRunner,
        parser: OptionParser.new do |opts|
          opts.banner = "Usage: #{NAME} upload"
        end,
        argv: md_json_argv_proc,
      }
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
    Array(globs)
      .map { |glob| result = Dir.glob(glob); result.empty? ? glob : result }
      .flatten
      .sort
      .delete_if { |file| file =~ /\.(variables||metadata)\.json/ }
      .map { |template| template.sub(/\.json$/, "") }
  end
end

class ListRunner
  include Common

  attr_reader :templates

  def initialize(opts)
    @templates = opts.template_files
  end

  def start
    templates.each { |template| puts template }
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
