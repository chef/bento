require "yaml"

desc "clean, build, test, upload"
task :do_all do
  check_env
  templates.each do |template|
    Rake::Task["clean"].invoke
    Rake::Task["clean"].reenable
    sh build_cmd(template)
    sh "bento test"
    unless ENV["BENTO_AUTO_RELEASE"].nil?
      sh "bento upload"
      sh "bento release #{template} #{ENV["BENTO_VERSION"]}"
    end
  end
end

desc "clean"
task :clean do
  sh "rm -rf builds/* .kitchen.yml"
end

def build_cmd(template)
  cmd = %W{bento build #{template}.json}
  cmd.insert(2, "--only #{providers}")
  cmd.insert(2, "--mirror #{ENV['PACKER_MIRROR']}") if ENV["PACKER_MIRROR"]
  cmd.insert(2, "--version #{ENV['BENTO_VERSION']}")
  cmd.join(" ")
  a_to_s(cmd)
end

def check_env
  if ENV["BENTO_VERSION"].nil?
    puts "Please set the BENTO_VERSION env variable"
    exit 1
  end
end

def providers
  if config['providers']
    config['providers'].join(',')
  else
    puts "No Providers Specified."
    puts "Set `providers` in builds.yml"
    exit 1
  end
end

def a_to_s(*args)
  clean_array(*args).join(" ")
end

def config
  YAML.load(File.read("builds.yml"))
end

def clean_array(*args)
  args.flatten.reject { |i| i.nil? || i == "" }.map(&:to_s)
end

def templates
  bit32 = []
  bit64 = []
  config['public'].each do |platform, versions|
    versions.each do |version, archs|
      archs.each do |arch|
        case arch
        when "i386"
          bit32 << "#{platform}/#{platform}-#{version}-#{arch}"
        else
          bit64 << "#{platform}/#{platform}-#{version}-#{arch}"
        end
      end
    end
  end
  bit64 + bit32
end
