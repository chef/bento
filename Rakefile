require 'yaml'
require 'fileutils'

desc 'Validate all templates using Packer'
task :validate do
  Dir.glob('os_pkrvars/**/*.pkrvars.hcl').sort.each do |template_path|
    template_dir = File.dirname(template_path)
    filename = File.basename(template_path)

    puts "\n\e[32mValidating #{template_path}\e[0m\n\n"
    result = system("packer validate -var-file=#{filename} ../../packer_templates", chdir: template_dir)
    raise "Validation for #{template_path} failed" unless result
  end
end

desc 'clean repo, build boxes, test, and upload/release'
task :do_all do
  check_env
  public_templates.each do |template|
    next unless config['public'].include?(box_name(template))
    Rake::Task[:clean].execute
    sh build_cmd(template)
    sh 'bento test'
    if ENV['BENTO_AUTO_RELEASE'].nil? || ENV['BENTO_VERSION'].nil?
      puts "skipping the upload / release of #{template} as BENTO_AUTO_RELEASE and BENTO_VERSION env vars were not set"
    else
      sh 'bento upload'
    end
  end
end

desc 'clean'
task :clean do
  puts 'Removing kitchen.yml and builds/*'
  FileUtils.rm_rf(['kitchen.yml', 'bootstrap.sh', Dir.glob('builds/*')])
end

def build_cmd(template)
  cmd = %W(bento build --var-file=#{template} ../../packer_templates)
  cmd.insert(2, "--only #{providers}")
  cmd.join(' ')
  a_to_s(cmd)
end

def providers
  if config['providers']
    config['providers'].join(',')
  else
    puts 'No Providers Specified.'
    puts 'Set `providers` in builds.yml'
    exit 1
  end
end

def a_to_s(*args)
  clean_array(*args).join(' ')
end

def config
  YAML.load(File.read('builds.yml'))
end

def clean_array(*args)
  args.flatten.reject { |i| i.nil? || i == '' }.map(&:to_s)
end

def box_name(template)
  bn = template.split('/')[1].gsub!(/\.pkrvars\.hcl/, '')
  bn.match(/-x86_64|-aarch64/) ? bn.gsub(/-x86_64|-aarch64/, '') : bn
end

def public_templates
  templates = Dir.glob('**/*.json').reject { |d| d['builds'] }
  templates.reject { |f| f[/macos|rhel|sles|solaris|windows/] }
end
