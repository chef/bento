# vi: ft=ruby

require 'thor'
require 'fileutils'
require 'timeout'

class Packer < Thor

  desc 'validate', "Validate all the packer templates"
  def validate
    Dir.chdir './packer' do
      templates = Dir.glob("*.json")
      templates.each do |template|
        puts "#{template}"
        unless system "packer validate #{template}"
          fail "Validation failed!"
        end
        puts "\n"
      end
    end
  end

  desc 'clean', "Description goes here"
  def clean(what)
    if what == "cache"
      FileUtils.rm_rf(Dir.glob('./packer/packer_cache/*'))
    elsif what == "boxes"
      FileUtils.rm_rf(Dir.glob('./packer/*.box'))
    end
  end

  desc 'build', "Execute the packer builder"
  option :os, :banner => "<os>", :default => "*"
  option :ver, :banner => "<version>", :default => "*"
  option :bits, :banner => "<bits>"
  option :only, :banner => "<only>"


  def build
    if options[:bits] 
      processor = options[:bits] == "64" ? "{amd64,x86_64}" : "i386"
    else
      processor = "*"
    end

    templates = Dir.glob("#{options[:os]}-#{options[:ver]}-#{processor}.json")

    if options[:only]
      templates.each do |template|
        name = template.chomp(".json").split("-")
        system "packer build -only=#{name[0]}-#{name[1]}-#{name[2]}-#{options[:only]} #{template}"
      end
    else
      templates.each do |template|
        system "packer build #{template}"
      end
    end
  end

end
