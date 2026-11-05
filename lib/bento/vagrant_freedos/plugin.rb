# frozen_string_literal: true

#
# @file plugin.rb
# @brief Vagrant Plugin registration for the Bento FreeDOS Suite (`Bento::VagrantFreedos::Plugin`)
# @description
#   Registers the `:freedos` configuration block, `:freedos` guest OS & capabilities,
#   `:freedos` / `:freedos_serial` / `:freedos_telnet` communicator, `:freedos_sync`
#   bidirectional synced folder implementation, `vagrant freedos-ssh` / `vagrant ssh`
#   polyfill hooks, and `vagrant freedos-sync` CLI command. Works both inside a live
#   Vagrant runtime and in standalone RSpec test environments.
#

require_relative 'config'
require_relative 'guest'
require_relative 'communicator'
require_relative 'command_ssh'
require_relative 'synced_folder'
require_relative 'command_sync'

module Bento
  module VagrantFreedos
    #
    # @class Plugin
    # @description
    #   Main descriptor class registering all FreeDOS components with Vagrant
    #   (or storing component metadata when loaded outside the Vagrant runtime).
    #
    class Plugin
      #
      # Returns the hash of registered plugin components for inspection and testing.
      #
      # @return [Hash<Symbol, Hash>] Map of component types to registered handlers.
      #
      def self.registered_components
        @registered_components ||= {
          configs: { freedos: Config },
          guests: { freedos: Guest },
          communicators: {
            freedos: Communicator,
            freedos_serial: Communicator,
            freedos_telnet: Communicator
          },
          synced_folders: { freedos_sync: SyncedFolder },
          commands: {
            'freedos-ssh' => CommandSsh,
            'freedos-sync' => CommandSync
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
          name 'bento-vagrant-freedos'
          description 'FreeDOS Telnet/Serial Communicator, vagrant ssh Polyfill, and Bidirectional Synced Folders'

          config(:freedos) { Bento::VagrantFreedos::Config }
          guest(:freedos) { Bento::VagrantFreedos::Guest }
          communicator(:freedos) { Bento::VagrantFreedos::Communicator }
          communicator(:freedos_serial) { Bento::VagrantFreedos::Communicator }
          communicator(:freedos_telnet) { Bento::VagrantFreedos::Communicator }
          synced_folder(:freedos_sync, 15) { Bento::VagrantFreedos::SyncedFolder }
          command('freedos-ssh') { Bento::VagrantFreedos::CommandSsh }
          command('freedos-sync') { Bento::VagrantFreedos::CommandSync }
        end
        true
      end
    end
  end
end
