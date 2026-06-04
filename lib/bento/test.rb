require 'bento/common'
require 'erb' unless defined?(Erb)
require 'kitchen'

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
        test_box(metadata_file)
      end
    end
    banner("Testing finished in #{duration(time.real)}.")
    if errors.empty?
      banner('All tests passed.')
    else
      raise("Failed Tests:\n#{errors.join("\n")}")
    end
  end

  private

  # Merge a single provider entry into an existing metadata JSON file,
  # appending or replacing by provider name. When creating a new file the
  # base metadata fields are copied but the providers list starts empty so
  # only the current provider is written on the first call.
  def update_metadata_file(path, base_md, provider)
    existing = File.exist?(path) ? JSON.parse(File.read(path)) : base_md.merge('providers' => [])
    existing['providers'].reject! { |p| p['name'] == provider['name'] }
    existing['providers'] << provider
    File.binwrite(path, JSON.pretty_generate(existing))
  end

  # Wrap block in Bundler.with_unbundled_env when Bundler is loaded (i.e. when
  # invoked via `bundle exec`), so that BUNDLE_GEMFILE and RUBYOPT are cleared
  # before vagrant subprocesses are spawned.  When bento is installed and run
  # as a plain gem (no bundler in scope) those env-vars are absent anyway, so
  # we simply yield the block.
  def with_unbundled_env(&block)
    if defined?(Bundler)
      Bundler.with_unbundled_env(&block)
    else
      block.call
    end
  end

  # Remove the vagrant box that was added during testing.
  # First tries with --provider; if that fails (e.g. qemu boxes register as
  # libvirt internally) falls back to removing all versions of the box name.
  def remove_vagrant_box(box_name, provider_name)
    vagrant_name = "bento-#{box_name}"
    cmd = Mixlib::ShellOut.new("vagrant box remove #{vagrant_name} --provider #{provider_name} --force")
    cmd.run_command
    unless cmd.error?
      banner("Removed vagrant box #{vagrant_name} (#{provider_name})")
      return
    end

    # Fall back to removing all registered providers/versions for this box name
    fallback = Mixlib::ShellOut.new("vagrant box remove #{vagrant_name} --all --force")
    fallback.run_command
    if fallback.error?
      warn("Failed to remove vagrant box #{vagrant_name}: #{fallback.stderr.strip}")
    else
      banner("Removed vagrant box #{vagrant_name} (all providers)")
    end
  end

  # Remove a provider entry from the build_complete metadata file.
  # Deletes the metadata file when the last provider has been removed.
  def remove_from_build_complete(build_complete_dir, md_json_file, provider_name)
    bc_md_path = File.join(build_complete_dir, md_json_file)
    return unless File.exist?(bc_md_path)

    bc_md = JSON.parse(File.read(bc_md_path))
    bc_md['providers'].reject! { |p| p['name'] == provider_name }
    if bc_md['providers'].empty?
      File.delete(bc_md_path)
    else
      File.binwrite(bc_md_path, JSON.pretty_generate(bc_md))
    end
  end

  def test_box(md_json)
    md = box_metadata(md_json)
    box_errors = []
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

    # Wrap all kitchen/vagrant operations in with_unbundled_env so that
    # bundler environment variables (BUNDLE_GEMFILE, RUBYOPT, etc.) set by
    # `bundle exec` are cleared before vagrant subprocesses are spawned.
    # Vagrant ships its own embedded Ruby and will fail if it inherits the
    # project's BUNDLE_GEMFILE.
    with_unbundled_env do
      kitchen_config = Kitchen::Config.new(
        kitchen_root: kitchen_dir,
        log_level: @debug ? :debug : :info
      )

      providers_to_test = if regx
                            box_name = regx.tr('.', '').tr('_', '-')
                            md['providers'].select { |p| "#{@boxname.tr('.', '')}-#{@arch}-#{p['name'].tr('_', '-')}" =~ /#{box_name}/i }
                          else
                            md['providers']
                          end

      providers_to_test.each do |provider|
        box_name = "#{@boxname.tr('.', '')}-#{@arch}-#{provider['name'].tr('_', '-')}"
        banner("Testing #{box_name}")

        instance = kitchen_config.instances.get("default-#{box_name}")
        if instance.nil?
          banner("No kitchen instance found for #{box_name}, skipping")
          next
        end

        begin
          instance.test(:always)
          banner("Testing passed for #{provider['file']}")
          provider['testing'] = 'passed'
          FileUtils.mkdir_p(test_passed_dir) unless Dir.exist?(test_passed_dir)
          update_metadata_file(File.join(test_passed_dir, md_json_file), md, provider)
          FileUtils.mv(File.join(build_complete_dir, provider['file']), File.join(test_passed_dir, provider['file']), force: true)
          remove_from_build_complete(build_complete_dir, md_json_file, provider['name'])
          remove_vagrant_box(@boxname, provider['name'])
          # Remove from failed metadata if it was previously recorded there
          failed_md_path = File.join(test_failed_dir, md_json_file)
          if File.exist?(failed_md_path)
            failed_md = JSON.parse(File.read(failed_md_path))
            failed_md['providers'].reject! { |p| p['name'] == provider['name'] }
            if failed_md['providers'].empty?
              File.delete(failed_md_path)
            else
              File.binwrite(failed_md_path, JSON.pretty_generate(failed_md))
            end
          end
        rescue Kitchen::ActionFailed, Kitchen::InstanceFailure => e
          banner("Testing failed for #{provider['file']}")
          provider['testing'] = "failed: #{e.message}"
          errors << provider['file']
          box_errors << provider['file']
          FileUtils.mkdir_p(test_failed_dir) unless Dir.exist?(test_failed_dir)
          update_metadata_file(File.join(test_failed_dir, md_json_file), md, provider)
          box_src = File.join(build_complete_dir, provider['file'])
          FileUtils.mv(box_src, File.join(test_failed_dir, provider['file']), force: true) if File.exist?(box_src)
          remove_from_build_complete(build_complete_dir, md_json_file, provider['name'])
          remove_vagrant_box(@boxname, provider['name'])
        end
      end

      banner("Cleaning up test files for #{@boxname}")
      kitchen_config.instances.each do |inst|
        begin
          inst.destroy
        rescue Kitchen::ActionFailed, Kitchen::InstanceFailure => e
          warn("Failed to destroy instance #{inst.name}: #{e.message}")
        end
      end
    end
    Dir.chdir(bento_dir)
    if box_errors.empty?
      FileUtils.rm_rf(kitchen_dir)
      prune = Mixlib::ShellOut.new('vagrant global-status --prune')
      prune.run_command
    else
      banner("Keeping #{kitchen_dir} for troubleshooting (#{box_errors.length} failed provider(s))")
    end
  end
end
