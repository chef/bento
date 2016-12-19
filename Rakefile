require 'json'
require 'yaml'

# TODO:  private boxes may need to specify a mirror

# Enables `bundle exec rake do_all[ubuntu-12.04-amd64,centos-7.1-x86_64]
# http://blog.stevenocchipinti.com/2013/10/18/rake-task-with-an-arbitrary-number-of-arguments/
builds = YAML.load(File.read("builds.yml"))

desc 'Do ALL THE THINGS'
task :do_all do
  # build stage
  builds['public'].each do |platform, versions|
    versions.each do |version, archs|
      archs.each do |arch|
        builds['providers'].each do |provider|
          # build stage
          Rake::Task['build_box'].invoke("#{platform}-#{version}-#{arch}", "#{provider}")
          Rake::Task['build_box'].reenable
          puts "#{platform}-#{version}-#{arch}, #{provider}"
          # verification stage
          Rake::Task['test_all'].invoke
          Rake::Task['test_all'].reenable
          # publish stage
          Rake::Task['upload_all'].invoke
          Rake::Task['upload_all'].reenable
          # release stage
          Rake::Task['release_all'].invoke
          Rake::Task['release_all'].reenable
          # clean stage
          Rake::Task['clean'].invoke
          Rake::Task['clean'].reenable
        end
      end
    end
  end
end

desc 'Test all boxes with Test Kitchen'
task :test_all do
  sh 'bento test -f'
end

desc 'Upload all boxes to Atlas for all providers'
task :upload_all do
  sh 'bento upload'
end

desc 'Release all'
task :release_all do
  metadata_files.each do |metadata_file|
    metadata = box_metadata(metadata_file)
    Rake::Task['release'].invoke(metadata['name'], metadata['version'])
    Rake::Task['release'].reenable
  end
end

desc 'Build a bento template'
task :build_box, :template, :provider do |_, args|
  bento_provider = ENV['BENTO_PROVIDERS'] ? ENV['BENTO_PROVIDERS'] : args[:provider]
  cmd = %W(bento build #{args[:template]})
  cmd.insert(2, "--only #{bento_provider}")
  cmd.insert(2, "--mirror #{ENV['PACKER_MIRROR']}") if ENV['PACKER_MIRROR']
  cmd.insert(2, "--version #{ENV['BENTO_VERSION']}") if ENV['BENTO_VERSION']
  cmd.insert(2, "--headless")
  cmd.join(' ')
  sh a_to_s(cmd)
end

desc 'Release a version of a box'
task :release, [:boxname, :version] do |_, args|
  sh "bento release #{args[:boxname]} #{args[:version]}"
end

desc 'Revoke a version of a box'
task :revoke, [:boxname, :version] do |_, args|
  sh "bento revoke #{args[:boxname]} #{args[:version]}"
end

desc 'Delete a version of a box'
task :delete, [:boxname, :version] do |_, args|
  sh "bento delete #{args[:boxname]} #{args[:version]}"
end

desc 'Clean the build directory'
task :clean do
  puts 'Cleaning up...'
  `rm -rf builds/*.json builds/*.box packer-* .kitchen.*.yml`
end

def a_to_s(*args)
  clean_array(*args).join(" ")
end

def clean_array(*args)
  args.flatten.reject { |i| i.nil? || i == "" }.map(&:to_s)
end

def box_metadata(metadata_file)
  metadata = {}
  file = File.read(metadata_file)
  json = JSON.parse(file)

  # metadata needed for upload:  boxname, version, provider, box filename
  metadata['name'] = json['name']
  metadata['version'] = json['version']
  metadata['box_basename'] = json['box_basename']
  metadata['providers'] = {}
  json['providers'].each do |provider|
    metadata['providers'][provider['name']] = provider.reject { |k, _| k == 'name' }
  end
  metadata
end

def metadata_files
  @metadata_files ||= compute_metadata_files
end

def compute_metadata_files
  `ls builds/*.json`.split("\n")
end

