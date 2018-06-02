#
# Author:: Doug MacEachern (<dougm@vmware.com>)
# Author:: Seth Chisamore (<schisamo@chef.io>)
# Author:: Wade Peacock (<wade.peacock@visioncritical.com>)
# Cookbook:: windows
# Resource:: zipfile
#
# Copyright:: 2010-2017, VMware, Inc.
# Copyright:: 2011-2018, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

provides :windows_zipfile

property :path, String, name_property: true
property :source, String
property :overwrite, [true, false], default: false
property :checksum, String

action :unzip do
  ensure_rubyzip_gem_installed
  Chef::Log.debug("unzip #{new_resource.source} => #{new_resource.path} (overwrite=#{new_resource.overwrite})")

  cache_file_path = if new_resource.source =~ %r{^(file|ftp|http|https):\/\/} # http://rubular.com/r/DGoIWjLfGI
                      uri = as_uri(new_resource.source)
                      local_cache_path = "#{Chef::Config[:file_cache_path]}/#{::File.basename(::URI.unescape(uri.path))}"
                      Chef::Log.debug("Caching a copy of file #{new_resource.source} at #{cache_file_path}")

                      remote_file local_cache_path do
                        source new_resource.source
                        backup false
                        checksum new_resource.checksum unless new_resource.checksum.nil?
                      end

                      local_cache_path
                    else
                      new_resource.source
                    end

  cache_file_path = win_friendly_path(cache_file_path)

  converge_by("unzip #{new_resource.source}") do
    ruby_block 'Unzipping' do
      block do
        Zip::File.open(cache_file_path) do |zip|
          zip.each do |entry|
            path = ::File.join(new_resource.path, entry.name)
            FileUtils.mkdir_p(::File.dirname(path))
            if new_resource.overwrite && ::File.exist?(path) && !::File.directory?(path)
              FileUtils.rm(path)
            end
            zip.extract(entry, path) unless ::File.exist?(path)
          end
        end
      end
      action :run
    end
  end
end

action :zip do
  ensure_rubyzip_gem_installed
  # sanitize paths for windows.
  new_resource.source.downcase.gsub!(::File::SEPARATOR, ::File::ALT_SEPARATOR)
  new_resource.path.downcase.gsub!(::File::SEPARATOR, ::File::ALT_SEPARATOR)
  Chef::Log.debug("zip #{new_resource.source} => #{new_resource.path} (overwrite=#{new_resource.overwrite})")

  if new_resource.overwrite == false && ::File.exist?(new_resource.path)
    Chef::Log.info("file #{new_resource.path} already exists and overwrite is set to false, exiting")
  else
    # delete the archive if it already exists, because we are recreating it.
    if ::File.exist?(new_resource.path)
      converge_by("delete existing file at #{new_resource.path}") do
        ::File.unlink(new_resource.path)
      end
    end

    # only supporting compression of a single directory (recursively).
    if ::File.directory?(new_resource.source)
      converge_by("zipping #{new_resource.source} to #{new_resource.path}") do
        z = Zip::File.new(new_resource.path, true)
        unless new_resource.source =~ /::File::ALT_SEPARATOR$/
          new_resource.source << ::File::ALT_SEPARATOR
        end
        Find.find(new_resource.source) do |f|
          f.downcase.gsub!(::File::SEPARATOR, ::File::ALT_SEPARATOR)
          # don't add root directory to the zipfile.
          next if f == new_resource.source
          # strip the root directory from the filename before adding it to the zipfile.
          zip_fname = f.sub(new_resource.source, '')
          Chef::Log.debug("adding #{zip_fname} to archive, sourcefile is: #{f}")
          z.add(zip_fname, f)
        end
        z.close
      end
    else
      Chef::Log.info("Single directory must be specified for compression, and #{new_resource.source} does not meet that criteria.")
    end
  end
end

action_class do
  include Windows::Helper
  require 'find'

  def ensure_rubyzip_gem_installed
    require 'zip'
  rescue LoadError
    Chef::Log.info("Missing gem 'rubyzip'...installing now.")
    chef_gem 'rubyzip' do
      action :install
      compile_time true
    end
    require 'zip'
  end
end
