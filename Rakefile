require "json"
require "yaml"

# TODO:  private boxes may need to specify a mirror

# Enables `bundle exec rake do_all[ubuntu-12.04-amd64,centos-7.1-x86_64]
# http://blog.stevenocchipinti.com/2013/10/18/rake-task-with-an-arbitrary-number-of-arguments/
builds = YAML.load(File.read("builds.yml"))

desc "Do ALL THE THINGS"
task :do_all do
  # build stage
  builds["public"].each do |platform, versions|
    versions.each do |version, archs|
      archs.each do |arch|
        builds["providers"].each do |provider|
          template = "#{platform}-#{version}-#{arch}"
          # build stage
          Rake::Task["build_box"].invoke(template, provider)
          Rake::Task["build_box"].reenable
          # verification stage
          sh "bento test -f"
          # publish stage
          sh "bento upload"
          # release stage
          atlas_name =  template.match(/-x86_64|-amd64/) ? template.gsub(/-x86_64|-amd64/,'') : template
          sh "bento release #{atlas_name} #{ENV['BENTO_VERSION']}"
          # clean stage
          puts "Cleaning up..."
          sh "rm -rf builds/*.json builds/*.box packer-* .kitchen.*.yml"
        end
      end
    end
  end
end

desc "Build a bento template"
task :build_box, :template, :provider do |_, args|
  bento_provider = ENV["BENTO_PROVIDERS"] ? ENV["BENTO_PROVIDERS"] : args[:provider]
  if bento_provider.nil?
    puts "Invalid build arguments. Either set BENTO_PROVIDERS in ENV or pass provider argument. Example: rake build_box[debian-8.7-amd64, virtualbox-iso]"
    exit 1
  end
  cmd = %W{bento build #{args[:template]}}
  cmd.insert(2, "--only #{bento_provider}")
  cmd.insert(2, "--mirror #{ENV['PACKER_MIRROR']}") if ENV["PACKER_MIRROR"]
  cmd.insert(2, "--version #{ENV['BENTO_VERSION']}") if ENV["BENTO_VERSION"]
  cmd.insert(2, "--headless")
  cmd.join(" ")
  sh a_to_s(cmd)
end

def a_to_s(*args)
  clean_array(*args).join(" ")
end

def clean_array(*args)
  args.flatten.reject { |i| i.nil? || i == "" }.map(&:to_s)
end
