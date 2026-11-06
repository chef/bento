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
    #   Provides unified registration metadata and Vagrant v2 plugin hooks for
    #   Microsoft MS-DOS (1.25, 2.0, 4.0) guests.
    #
    class Plugin
      #
      # Returns the map of all registered plugin components for inspection and testing.
      #
      # @return [Hash<Symbol, Object>] Registered configs, guests, communicators, synced folders, and commands.
      #
      def self.registered_components
        {
          configs: { msdos: Config },
          guests: { msdos: Guest },
          guest_capabilities: {
            halt: GuestCapHalt,
            change_host_name: GuestCapChangeHostName,
            mount_shared_folder: GuestCapMountSharedFolder
          },
          communicators: {
            msdos: Communicator,
            msdos_serial: Communicator,
            msdos_telnet: Communicator
          },
          synced_folders: { msdos_sync: SyncedFolder },
          commands: {
            'ssh' => CommandSsh,
            'msdos-ssh' => CommandSsh,
            'msdos-sync' => CommandSync
          }
        }
      end

      #
      # Dynamically registers the MS-DOS plugin components with `Vagrant.plugin("2")`
      # if the Vagrant runtime is loaded in the current Ruby process.
      #
      # @param [Module, nil] vagrant_mod The `Vagrant` module (if available).
      # @return [Boolean] True if registered with Vagrant, false otherwise.
      #
      def self.register_with_vagrant!(vagrant_mod = (Object.const_get(:Vagrant) if Object.const_defined?(:Vagrant)))
        return false unless vagrant_mod && vagrant_mod.respond_to?(:plugin)

        base_class = vagrant_mod.plugin('2')
        Class.new(base_class) do
          name 'bento-vagrant-msdos'
          description 'Bento MS-DOS (1.25, 2.0, 4.0) Serial/Telnet Communicator, SSH Polyfill, and Bidirectional Synced Folders'

          config(:msdos) { Bento::VagrantMsdos::Config }
          guest(:msdos) { Bento::VagrantMsdos::Guest }
          if respond_to?(:guest_capability)
            guest_capability(:msdos, :halt) { Bento::VagrantMsdos::GuestCapHalt }
            guest_capability(:msdos, :change_host_name) { Bento::VagrantMsdos::GuestCapChangeHostName }
            guest_capability(:msdos, :mount_shared_folder) { Bento::VagrantMsdos::GuestCapMountSharedFolder }
          end
          communicator(:msdos) { Bento::VagrantMsdos::Communicator }
          communicator(:msdos_serial) { Bento::VagrantMsdos::Communicator }
          communicator(:msdos_telnet) { Bento::VagrantMsdos::Communicator }
          synced_folder(:msdos_sync, 10) { Bento::VagrantMsdos::SyncedFolder }
          command('ssh') { Bento::VagrantMsdos::CommandSsh }
          command('msdos-ssh') { Bento::VagrantMsdos::CommandSsh }
          command('msdos-sync') { Bento::VagrantMsdos::CommandSync }

          if respond_to?(:action_hook) && vagrant_mod.const_defined?(:Action)
            builtin = vagrant_mod.const_get(:Action).const_get(:Builtin)
            action_hook(:msdos_ssh_run, :machine_action_ssh_run) do |hook|
              hook.before(builtin.const_get(:SSHRun), Bento::VagrantMsdos::CommandSsh)
            end
            action_hook(:msdos_ssh_exec, :machine_action_ssh) do |hook|
              hook.before(builtin.const_get(:SSHExec), Bento::VagrantMsdos::CommandSsh)
            end
          end
        end
        true
      end
    end
  end
end
