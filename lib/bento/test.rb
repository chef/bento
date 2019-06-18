require "bento/common"
require "mixlib/shellout"
require "erb"

class TestRunner
  include Common

  attr_reader :shared_folder, :boxname, :provider, :box_url, :no_shared, :provisioner

  def initialize(opts)
    @debug = opts.debug
    @no_shared = opts.no_shared
    @provisioner = opts.provisioner.nil? ? "shell" : opts.provisioner
  end

  def start
    banner("Starting testing...")
    time = Benchmark.measure do
      metadata_files.each do |metadata_file|
        destroy_all_bento
        test_box(metadata_file)
        destroy_all_bento
      end
    end
    banner("Testing finished in #{duration(time.real)}.")
  end

  private

  def destroy_all_bento
    cmd = Mixlib::ShellOut.new("vagrant box list | grep 'bento-'")
    cmd.run_command
    boxes = cmd.stdout.split("\n")

    boxes.each do |box|
      b = box.split(" ")
      rm_cmd = Mixlib::ShellOut.new("vagrant box remove --force #{b[0]} --provider #{b[1].to_s.gsub(/(,|\()/, '')}")
      banner("Removing #{b[0]} for provider #{b[1].to_s.gsub(/(,|\()/, '')}")
      rm_cmd.run_command
    end
  end

  def test_box(md_json)
    md = box_metadata(md_json)
    @boxname = md["name"]
    @providers = md["providers"]
    @share_disabled = no_shared || /(bsd|opensuse)/.match(boxname) ? true : false

    dir = "#{File.expand_path("../../", File.dirname(__FILE__))}/templates"
    %w{.kitchen.yml bootstrap.sh}.each do |file|
      t = file =~ /kitchen/ ? "kitchen.yml.erb" : "#{file}.erb"
      erb = ERB.new(File.read(dir + "/#{t}"), nil, "-").result(binding)
      File.open(file, "w") { |f| f.puts erb }
    end

    test = Mixlib::ShellOut.new("kitchen test", timeout: 900, live_stream: STDOUT)
    test.run_command
    test.error!
  end
end
