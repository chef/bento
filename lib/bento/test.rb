require 'bento/common'
require 'mixlib/shellout' unless defined?(Mixlib::ShellOut)
require 'erb' unless defined?(Erb)

class TestRunner
  include Common

  attr_reader :shared_folder, :boxname, :provider, :box_url, :no_shared, :provisioner, :errors, :regx

  def initialize(opts)
    @debug = opts.debug
    @no_shared = opts.no_shared
    @provisioner = opts.provisioner.nil? ? 'shell' : opts.provisioner
    @errors = []
    @regx = opts.regx || nil
  end

  def start
    banner('Starting testing...')
    md_files = metadata_files(true)
    puts md_files.join("\n")
    time = Benchmark.measure do
      md_files.each do |metadata_file|
        destroy_all_bento
        test_box(metadata_file)
        destroy_all_bento
      end
    end
    banner("Testing finished in #{duration(time.real)}.")
    unless errors.empty?
      raise("Failed Tests:\n#{errors.join("\n")}\nexited #{$CHILD_STATUS}")
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
             raise "Unknown arch #{md['arch'].inspect}"
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
    if regx
      test = Mixlib::ShellOut.new("kitchen test #{regx.tr('.', '').tr('_', '-')}", timeout: 900, live_stream: STDOUT)
      test.run_command
      if test.error?
        puts test.stderr
        errors << "#{regex}"
      end
    else
      @providers.each do |k, v|
        banner("Testing #{@boxname.tr('.', '')}-#{@arch}-#{k.tr('_', '-')}")
        test = Mixlib::ShellOut.new("kitchen test #{@boxname.tr('.', '')}-#{@arch}-#{k.tr('_', '-')}", timeout: 900, live_stream: STDOUT)
        test.run_command
        next unless test.error?
        puts test.stderr
        errors << "#{@boxname}-#{@arch}-#{k}"
        FileUtils.cp(File.join(bento_dir, md_json), File.join(bento_dir, 'builds', 'failed_testing', File.basename(md_json))) unless File.exist?(File.join(bento_dir, 'builds', 'failed_testing', File.basename(md_json)))
        FileUtils.mv(File.join(bento_dir, 'builds', v['file']), File.join(bento_dir, 'builds', 'failed_testing', v['file']))
        @providers.delete(k)
        if @providers.empty?
          File.delete(File.join(bento_dir, md_json)) if File.exist?(File.join(bento_dir, md_json))
        else
          File.binwrite(File.join(bento_dir, md_json), JSON.pretty_generate(md))
        end
      end
    end
    destroy = Mixlib::ShellOut.new('kitchen destroy', timeout: 900, live_stream: STDOUT)
    destroy.run_command
    Dir.chdir(bento_dir)
    FileUtils.rm_rf(temp_dir)
  end
end
