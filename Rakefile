require "yaml"

desc "clean, build, test, upload"
task :do_all do
  check_env
  templates.each do |template|
    Rake::Task["clean"].invoke
    Rake::Task["clean"].reenable

    Rake::Task["build"].invoke(template)
    Rake::Task["build"].reenable

    Rake::Task["test"].invoke
    Rake::Task["test"].reenable

    Rake::Task["upload"].invoke
    Rake::Task["upload"].reenable

    unless ENV["BENTO_AUTO_RELEASE"].nil?
      Rake::Task["release"].invoke(template)
      Rake::Task["release"].reenable
    end
  end
end

desc "Build a bento template"
task :build, :template do |_, args|
  cmd = %W{bento build #{args[:template]}}
  cmd.insert(2, "--only #{providers}")
  cmd.insert(2, "--mirror #{ENV['PACKER_MIRROR']}") if ENV["PACKER_MIRROR"]
  cmd.insert(2, "--version #{ENV['BENTO_VERSION']}") if ENV["BENTO_VERSION"]
  cmd.join(" ")
  sh a_to_s(cmd)
end

desc "release"
task :release, :template do |_, args|
  puts "bento release #{box_name(args[:template])} #{ENV['BENTO_VERSION']}"
end

desc "test"
task :test do
  sh "bento test"
end

desc "upload"
task :upload do
  sh "bento upload"
end

desc "Clean"
task :clean do
  sh "rm -rf builds/*.json builds/*.box packer-* .kitchen.yml"
end

def a_to_s(*args)
  clean_array(*args).join(" ")
end

def box_name(template)
  template.match(/-x86_64|-amd64/) ? template.gsub(/-x86_64|-amd64/,'') : template
end

def builds
  YAML.load(File.read("builds.yml"))
end

def check_env
  if ENV["BENTO_VERSION"].nil?
    puts "Please set the BENTO_VERSION env variable"
    exit 1
  end
end

def providers
  if ENV["BENTO_PROVIDERS"]
    ENV["BENTO_PROVIDERS"]
  elsif builds['providers']
    builds['providers'].join(',')
  else
    puts "No Providers Specified."
    puts "Set BENTO_PROVIDERS in ENV or `providers` in builds.yml"
    exit 1
  end
end

def clean_array(*args)
  args.flatten.reject { |i| i.nil? || i == "" }.map(&:to_s)
end

def templates
  bit32 = []
  bit64 = []
  builds['public'].each do |platform, versions|
    versions.each do |version, archs|
      archs.each do |arch|
        case arch
        when "i386"
          bit32 << "#{platform}-#{version}-#{arch}"
        else
          bit64 << "#{platform}-#{version}-#{arch}"
        end
      end
    end
  end
  bit64 + bit32
end
