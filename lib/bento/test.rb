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
    md_files.each do |file|
      puts File.absolute_path(file)
    end
    time = Benchmark.measure do
      md_files.each do |metadata_file|
        destroy_all_bento
        test_box(metadata_file)
        destroy_all_bento
      end
    end
    banner("Testing finished in #{duration(time.real)}.")
    if errors.empty?
      banner('All tests passed.')
    else
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
    md = box_metadata(md_json)
    bento_dir = Dir.pwd
    build_dir = File.join(bento_dir, 'builds')
    build_complete_dir = File.join(build_dir, 'build_complete')
    kitchen_dir = File.join(build_dir, 'test-kitchen')
    test_passed_dir = File.join(build_dir, 'testing_passed', md['arch'])
    test_failed_dir = File.join(build_dir, 'testing_failed', md['arch'])
    md_json_file = File.basename(md_json)
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

    Dir.mkdir(kitchen_dir) unless Dir.exist?(kitchen_dir)
    template_dir = "#{File.expand_path('../../', File.dirname(__FILE__))}/lib/bento/test_templates"
    %w(kitchen.yml bootstrap.sh).each do |file|
      t = file =~ /kitchen/ ? 'kitchen.yml.erb' : "#{file}.erb"
      erb = ERB.new(File.read(template_dir + "/#{t}"), trim_mode: '-').result(binding)
      File.open("#{kitchen_dir}/#{file}", 'w') { |f| f.puts erb }
    end
    banner("Test kitchen file created at #{kitchen_dir}/kitchen.yml")

    Dir.chdir(kitchen_dir)

    if regx
      box_name = regx.tr('.', '').tr('_', '-')
      test = Mixlib::ShellOut.new("kitchen test #{box_name}", timeout: 900, live_stream: STDOUT)
      test.run_command
      if test.error?
        errors << box_name
      end
    else
      passed_providers = []
      failed_providers = []
      new_md = md.dup
      new_md['providers'].each do |provider|
        box_name = "#{@boxname.tr('.', '')}-#{@arch}-#{provider['name'].tr('_', '-')}"
        banner("Testing #{box_name}")
        test = Mixlib::ShellOut.new("kitchen test #{box_name}", timeout: 900, live_stream: STDOUT)
        test.run_command
        if test.error?
          banner("Testing failed for #{provider['file']}")
          provider['testing'] = "failed: #{test.stderr}"
          failed_providers << provider
          errors << provider['file']
          new_md['providers'] = failed_providers
          FileUtils.mkdir_p(test_failed_dir) unless Dir.exist?(test_failed_dir)
          File.binwrite(File.join(test_failed_dir, md_json_file), JSON.pretty_generate(new_md))
          FileUtils.mv(File.join(build_complete_dir, provider['file']), File.join(test_failed_dir, provider['file']))
        else
          banner("Testing passed for #{provider['file']}")
          provider['testing'] = 'passed'
          passed_providers << provider
          new_md['providers'] = passed_providers
          FileUtils.mkdir_p(test_passed_dir) unless Dir.exist?(test_passed_dir)
          File.binwrite(File.join(test_passed_dir, md_json_file), JSON.pretty_generate(new_md))
          FileUtils.mv(File.join(build_complete_dir, provider['file']), File.join(test_passed_dir, provider['file']))
        end
      end
    end
    banner("Cleaning up test files for #{@boxname}")
    destroy = Mixlib::ShellOut.new('kitchen destroy', timeout: 900, live_stream: STDOUT)
    destroy.run_command
    if Dir.glob("#{build_complete_dir}/#{@boxname}-#{md['arch']}.*.box").empty?
      File.delete(File.join(bento_dir, md_json))
    end
    Dir.chdir(bento_dir)
    FileUtils.rm_rf(kitchen_dir)
  end
end
