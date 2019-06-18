#
# Author:: Seth Chisamore (<schisamo@chef.io>)
# Cookbook:: windows
# Library:: windows_helper
#
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

require 'uri'
require 'Win32API' if Chef::Platform.windows?
require 'chef/exceptions'
require 'openssl'
require 'chef/mixin/powershell_out'

module Windows
  module Helper
    AUTO_RUN_KEY = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'.freeze unless defined?(AUTO_RUN_KEY)
    ENV_KEY = 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment'.freeze unless defined?(ENV_KEY)
    ExpandEnvironmentStrings = Win32API.new('kernel32', 'ExpandEnvironmentStrings', %w(P P L), 'L') if Chef::Platform.windows? && !defined?(ExpandEnvironmentStrings)

    # returns windows friendly version of the provided path,
    # ensures backslashes are used everywhere
    def win_friendly_path(path)
      path.gsub(::File::SEPARATOR, ::File::ALT_SEPARATOR || '\\') if path
    end

    # account for Window's wacky File System Redirector
    # http://msdn.microsoft.com/en-us/library/aa384187(v=vs.85).aspx
    # especially important for 32-bit processes (like Ruby) on a
    # 64-bit instance of Windows.
    def locate_sysnative_cmd(cmd)
      if ::File.exist?("#{ENV['WINDIR']}\\sysnative\\#{cmd}")
        "#{ENV['WINDIR']}\\sysnative\\#{cmd}"
      elsif ::File.exist?("#{ENV['WINDIR']}\\system32\\#{cmd}")
        "#{ENV['WINDIR']}\\system32\\#{cmd}"
      else
        cmd
      end
    end

    # singleton instance of the Windows Version checker
    def win_version
      @win_version ||= Windows::Version.new
    end

    # Helper function to properly parse a URI
    def as_uri(source)
      URI.parse(source)
    rescue URI::InvalidURIError
      Chef::Log.warn("#{source} was an invalid URI. Trying to escape invalid characters")
      URI.parse(URI.escape(source))
    end

    # if a file is local it returns a windows friendly path version
    # if a file is remote it caches it locally
    def cached_file(source, checksum = nil, windows_path = true)
      @installer_file_path ||= begin

        if source =~ %r{^(file|ftp|http|https):\/\/}
          uri = as_uri(source)
          cache_file_path = "#{Chef::Config[:file_cache_path]}/#{::File.basename(::URI.unescape(uri.path))}"
          Chef::Log.debug("Caching a copy of file #{source} at #{cache_file_path}")
          remote_file cache_file_path do
            source source
            backup false
            checksum checksum unless checksum.nil?
          end.run_action(:create)
        else
          cache_file_path = source
        end

        windows_path ? win_friendly_path(cache_file_path) : cache_file_path
      end
    end

    # Expands the environment variables
    def expand_env_vars(path)
      # We pick 32k because that is the largest it could be:
      # http://msdn.microsoft.com/en-us/library/windows/desktop/ms724265%28v=vs.85%29.aspx
      buf = 0.chr * 32 * 1024 # 32k
      if ExpandEnvironmentStrings.call(path.dup, buf, buf.length) == 0
        raise Chef::Exceptions::Win32APIError, 'Failed calling ExpandEnvironmentStrings (received 0)'
      end
      buf.strip
    end

    def is_package_installed?(package_name) # rubocop:disable Naming/PredicateName
      installed_packages.include?(package_name)
    end

    def installed_packages
      @installed_packages || begin
        installed_packages = {}
        # Computer\HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall
        installed_packages.merge!(extract_installed_packages_from_key(::Win32::Registry::HKEY_LOCAL_MACHINE)) # rescue nil
        # 64-bit registry view
        # Computer\HKEY_LOCAL_MACHINE\Software\Wow6464Node\Microsoft\Windows\CurrentVersion\Uninstall
        installed_packages.merge!(extract_installed_packages_from_key(::Win32::Registry::HKEY_LOCAL_MACHINE, (::Win32::Registry::Constants::KEY_READ | 0x0100))) # rescue nil
        # 32-bit registry view
        # Computer\HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall
        installed_packages.merge!(extract_installed_packages_from_key(::Win32::Registry::HKEY_LOCAL_MACHINE, (::Win32::Registry::Constants::KEY_READ | 0x0200))) # rescue nil
        # Computer\HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Uninstall
        installed_packages.merge!(extract_installed_packages_from_key(::Win32::Registry::HKEY_CURRENT_USER)) # rescue nil
        installed_packages
      end
    end

    # Returns an array
    def to_array(var)
      var = var.is_a?(Array) ? var : [var]
      var.reject(&:nil?)
    end

    private

    def extract_installed_packages_from_key(hkey = ::Win32::Registry::HKEY_LOCAL_MACHINE, desired = ::Win32::Registry::Constants::KEY_READ)
      uninstall_subkey = 'Software\Microsoft\Windows\CurrentVersion\Uninstall'
      packages = {}
      begin
        ::Win32::Registry.open(hkey, uninstall_subkey, desired) do |reg|
          reg.each_key do |key, _wtime|
            begin
              k = reg.open(key, desired)
              display_name = begin
                               k['DisplayName']
                             rescue
                               nil
                             end
              version = begin
                          k['DisplayVersion']
                        rescue
                          'NO VERSION'
                        end
              uninstall_string = begin
                                   k['UninstallString']
                                 rescue
                                   nil
                                 end
              if display_name
                packages[display_name] = { name: display_name,
                                           version: version,
                                           uninstall_string: uninstall_string }
              end
            rescue ::Win32::Registry::Error
            end
          end
        end
      rescue ::Win32::Registry::Error
      end
      packages
    end
  end
end

Chef::Recipe.send(:include, Windows::Helper)
