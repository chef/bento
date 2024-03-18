require 'bento/common'
require 'mixlib/shellout' unless defined?(Mixlib::ShellOut)
require 'erb' unless defined?(Erb)

class TestRunner
  include Common

  attr_reader :shared_folder, :boxname, :provider, :box_url, :no_shared, :provisioner, :errors

  def initialize(opts)
    @debug = opts.debug
    @no_shared = opts.no_shared
    @provisioner = opts.provisioner.nil? ? 'shell' : opts.provisioner
    @errors = []
  end

  def start
    banner('Starting testing...')
    time = Benchmark.measure do
      metadata_files.each do |metadata_file|
        destroy_all_bento
        test_box(metadata_file)
        destroy_all_bento
      end
    end
    banner("Testing finished in #{duration(time.real)}.")
    unless errors.empty?
      raise("Failed Tests:\n #{errors.join("\n")}\n exited #{$CHILD_STATUS}")
    end
  end

  private

  def destroy_all_bento
    cmd = Mixlib::ShellOut.new("vagrant box list | grep 'bento-'")
    cmd.run_command
    boxes = cmd.stdout.split("\n")

    boxes.each do |box|
      b = box.split(' ')
      rm_cmd = Mixlib::ShellOut.new("vagrant box remove --force #{b[0]} --provider #{b[1].to_s.gsub(/(,|\()/, '')}")
      banner("Removing #{b[0]} for provider #{b[1].to_s.gsub(/(,|\()/, '')}")
      rm_cmd.run_command
    end
  end

  def test_box(md_json)
    bento_dir = Dir.pwd
    temp_dir = "#{bento_dir}/builds/test-kitchen"
    Dir.mkdir(temp_dir) unless Dir.exist?(temp_dir)
    md = box_metadata(md_json)
    arch = case md['arch']
           when 'x86_64', 'amd64'
             'amd64'
           when 'aarch64', 'arm64'
             'arm64'
           else
             raise "Unknown arch #{md_data.inspect}"
           end
    @boxname = md['name']
    @providers = md['providers']
    @arch = arch
    @share_disabled = no_shared || /(bsd|opensuse)/.match(boxname) ? true : false

    dir = "#{File.expand_path('../../', File.dirname(__FILE__))}/lib/bento/test_templates"
    %w(kitchen.yml bootstrap.sh).each do |file|
      t = file =~ /kitchen/ ? 'kitchen.yml.erb' : "#{file}.erb"
      erb = ERB.new(File.read(dir + "/#{t}"), trim_mode: '-').result(binding)
      File.open("#{temp_dir}/#{file}", 'w') { |f| f.puts erb }
    end

    Dir.chdir(temp_dir)
    banner("Test kitchen file located in #{temp_dir}")
    @providers.each do |k, _v|
      test = Mixlib::ShellOut.new("kitchen test #{@boxname}-#{@arch}-#{k.tr('_', '-')}", timeout: 900, live_stream: STDOUT)
      test.run_command
      if test.error?
        test.stderr
        errors << "#{@boxname}-#{@arch}-#{k}"
      end
    end
    Dir.chdir(bento_dir)
    FileUtils.rm_rf(temp_dir)
  end
end
