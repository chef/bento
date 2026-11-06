# frozen_string_literal: true

#
# @file plugin.rb
# @brief Vagrant Plugin registration for the Bento FreeDOS Suite (`Bento::VagrantFreedos::Plugin`)
# @description
#   Registers the `:freedos` configuration block, `:freedos` guest OS & capabilities,
#   `:freedos` / `:freedos_serial` / `:freedos_telnet` communicator, `:freedos_sync`
#   bidirectional synced folder implementation, `vagrant freedos-ssh` / `vagrant ssh`
#   polyfill hooks, and `vagrant freedos-sync` CLI command. Works both inside a live
#   Vagrant runtime (`Vagrant.plugin("2")`) and in standalone Ruby/RSpec environments.
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
    #   Provides unified registration metadata and Vagrant v2 plugin hooks for
    #   FreeDOS guests.
    #
    class Plugin
      #
      # Returns the map of all registered plugin components for inspection and testing.
      #
      # @return [Hash<Symbol, Object>] Registered configs, guests, communicators, synced folders, and commands.
      #
      def self.registered_components
        {
          configs: { freedos: Config },
          guests: { freedos: Guest },
          guest_capabilities: {
            halt: GuestCapHalt,
            change_host_name: GuestCapChangeHostName,
            mount_shared_folder: GuestCapMountSharedFolder
          },
          communicators: {
            freedos: Communicator,
            freedos_serial: Communicator,
            freedos_telnet: Communicator
          },
          synced_folders: { freedos_sync: SyncedFolder },
          commands: {
            'ssh' => CommandSsh,
            'freedos-ssh' => CommandSsh,
            'freedos-sync' => CommandSync
          }
        }
      end

      #
      # Dynamically registers the FreeDOS plugin components with `Vagrant.plugin("2")`
      # if the Vagrant runtime is loaded in the current Ruby process.
      #
      # @param [Module, nil] vagrant_mod The `Vagrant` module (if available).
      # @return [Boolean] True if registered with Vagrant, false otherwise.
      #
      def self.register_with_vagrant!(vagrant_mod = (Object.const_get(:Vagrant) if Object.const_defined?(:Vagrant)))
        return false unless vagrant_mod && vagrant_mod.respond_to?(:plugin)

        base_class = vagrant_mod.plugin('2')
        Class.new(base_class) do
          name 'bento-vagrant-freedos'
          description 'Bento FreeDOS Serial/Telnet Communicator, SSH Polyfill, and Bidirectional Synced Folders'

          config(:freedos) { Bento::VagrantFreedos::Config }
          guest(:freedos) { Bento::VagrantFreedos::Guest }
          if respond_to?(:guest_capability)
            guest_capability(:freedos, :halt) { Bento::VagrantFreedos::GuestCapHalt }
            guest_capability(:freedos, :change_host_name) { Bento::VagrantFreedos::GuestCapChangeHostName }
            guest_capability(:freedos, :mount_shared_folder) { Bento::VagrantFreedos::GuestCapMountSharedFolder }
          end
          communicator(:freedos) { Bento::VagrantFreedos::Communicator }
          communicator(:freedos_serial) { Bento::VagrantFreedos::Communicator }
          communicator(:freedos_telnet) { Bento::VagrantFreedos::Communicator }
          synced_folder(:freedos_sync, 10) { Bento::VagrantFreedos::SyncedFolder }
          command('ssh') { Bento::VagrantFreedos::CommandSsh }
          command('freedos-ssh') { Bento::VagrantFreedos::CommandSsh }
          command('freedos-sync') { Bento::VagrantFreedos::CommandSync }

          if respond_to?(:action_hook) && vagrant_mod.const_defined?(:Action)
            builtin = vagrant_mod.const_get(:Action).const_get(:Builtin)
            action_hook(:freedos_ssh_run, :machine_action_ssh_run) do |hook|
              hook.before(builtin.const_get(:SSHRun), Bento::VagrantFreedos::CommandSsh)
            end
            action_hook(:freedos_ssh_exec, :machine_action_ssh) do |hook|
              hook.before(builtin.const_get(:SSHExec), Bento::VagrantFreedos::CommandSsh)
            end
          end
        end
        true
      end
    end
  end
end
