# frozen_string_literal: true

#
# @file plugin.rb
# @brief Vagrant Plugin registration for the Bento MS-DOS Suite (`Bento::VagrantMsdos::Plugin`)
# @description
#   Registers the `:msdos` configuration block, `:msdos` guest OS & capabilities,
#   `:msdos` / `:msdos_serial` / `:msdos_telnet` communicator, `:msdos_sync`
#   bidirectional synced folder implementation, `vagrant msdos-ssh` / `vagrant ssh`
#   polyfill hooks, and `vagrant msdos-sync` CLI command for MS-DOS 1.25, 2.0, and 4.0.
#

require_relative 'config'
require_relative 'guest'
require_relative 'communicator'
require_relative 'command_ssh'
require_relative 'synced_folder'
require_relative 'command_sync'

module Bento
  module VagrantMsdos
    #
    # @class Plugin
    # @description
    #   Main descriptor class registering all MS-DOS (1.25, 2.0, 4.0) components
    #   with Vagrant (or storing component metadata when loaded outside Vagrant).
    #
    class Plugin
      #
      # Returns the hash of registered plugin components for inspection and testing.
      #
      # @return [Hash<Symbol, Hash>] Map of component types to registered handlers.
      #
      def self.registered_components
        @registered_components ||= {
          configs: { msdos: Config },
          guests: { msdos: Guest },
          communicators: {
            msdos: Communicator,
            msdos_serial: Communicator,
            msdos_telnet: Communicator
          },
          synced_folders: { msdos_sync: SyncedFolder },
          commands: {
            'msdos-ssh' => CommandSsh,
            'msdos-sync' => CommandSync
          }
        }
      end

      #
      # Registers the plugin components with `Vagrant.plugin("2")` when running inside Vagrant.
      #
      # @param [Module, nil] vagrant_mod Optional Vagrant module.
      # @return [Boolean] True if registered with Vagrant, false if Vagrant is not loaded.
      #
      def self.register_with_vagrant!(vagrant_mod = nil)
        return false unless vagrant_mod && vagrant_mod.respond_to?(:plugin)

        base_class = vagrant_mod.plugin('2')
        Class.new(base_class) do
          name 'bento-vagrant-msdos'
          description 'Microsoft MS-DOS (1.25, 2.0, 4.0) Telnet/Serial Communicator, vagrant ssh Polyfill, and Bidirectional Synced Folders'

          config(:msdos) { Bento::VagrantMsdos::Config }
          guest(:msdos) { Bento::VagrantMsdos::Guest }
          communicator(:msdos) { Bento::VagrantMsdos::Communicator }
          communicator(:msdos_serial) { Bento::VagrantMsdos::Communicator }
          communicator(:msdos_telnet) { Bento::VagrantMsdos::Communicator }
          synced_folder(:msdos_sync, 15) { Bento::VagrantMsdos::SyncedFolder }
          command('msdos-ssh') { Bento::VagrantMsdos::CommandSsh }
          command('msdos-sync') { Bento::VagrantMsdos::CommandSync }
        end
        true
      end
    end
  end
end
