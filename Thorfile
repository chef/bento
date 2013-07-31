
require 'bundler'
require 'thor/rake_compat'
require 'fileutils'


class Packer < Thor

  desc 'validate', "Validate all the packer templates"
  def validate
    Dir.chdir './packer' do
      templates = Dir.glob("*.json")
      templates.each do |template|
        puts "#{template}"
        system "packer validate #{template}"
        puts "\n"
      end
    end
  end

  desc 'clearcache', "Clear the packer_cache"
  def clearcache
    FileUtils.rm_rf(Dir.glob('packer/packer_cache/*'))
  end
end
