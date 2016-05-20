require 'json'

# TODO:  private boxes may need to specify a mirror

# Enables `bundle exec rake do_all[ubuntu-12.04-amd64,centos-7.1-x86_64]
# http://blog.stevenocchipinti.com/2013/10/18/rake-task-with-an-arbitrary-number-of-arguments/
task :do_all do |_task, args|
  args.extras.each do |a|
    # build stage
    Rake::Task['build_box'].invoke(a)
    Rake::Task['build_box'].reenable
  end

  # verification stage
  Rake::Task['test_all'].invoke
  Rake::Task['test_all'].reenable

  # publish stage
  Rake::Task['upload_all'].invoke
  Rake::Task['upload_all'].reenable

  # release stage
  Rake::Task['release_all'].invoke
  Rake::Task['release_all'].reenable
end

desc 'Test all boxes with Test Kitchen'
task :test_all do
  sh './bin/bento test'
end

desc 'Upload all boxes to Atlas and S3 for all providers'
task :upload_all do
  sh './bin/bento upload'
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
task :build_box, :template do |_, args|
  sh build_command(args[:template])
end

desc 'Release a version of a box'
task :release, [:boxname, :version] do |_, args|
  sh "./bin/bento release #{args[:boxname]} #{args[:version]}"
end

desc 'Revoke a version of a box'
task :revoke, [:boxname, :version] do |_, args|
  sh "./bin/bento revoke #{args[:boxname]} #{args[:version]}"
end

desc 'Delete a version of a box'
task :delete, [:boxname, :version] do |_, args|
  sh "./bin/bento delete #{args[:boxname]} #{args[:version]}"
end

desc 'Clean the build directory'
task :clean do
  puts 'Cleaning up...'
  `rm -rf builds/*.json builds/*.box packer-* .kitchen.*.yml`
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

def build_command(template)
  cmd = %W(./bin/bento build #{template})
  cmd.insert(2, "--only #{ENV['BENTO_PROVIDERS']}") if ENV['BENTO_PROVIDERS']
  cmd.insert(2, "--mirror #{ENV['PACKER_MIRROR']}") if ENV['PACKER_MIRROR']
  cmd.insert(2, "--version #{ENV['BENTO_VERSION']}") if ENV['BENTO_VERSION']
  cmd.insert(2, "--headless")
  cmd.join(' ')
end

def metadata_files
  @metadata_files ||= compute_metadata_files
end

def compute_metadata_files
  `ls builds/*.json`.split("\n")
end

# http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each do |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable?(exe) && !File.directory?(exe)
    end
  end
  false
end
