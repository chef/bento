# frozen_string_literal: true

#
# @file vagrant_freedos.rb
# @brief Main entry point for the Bento FreeDOS Vagrant Plugin Suite
# @description
#   Loads all components of `Bento::VagrantFreedos` (`Config`, `Guest`,
#   `Communicator`, `CommandSsh`, `SyncedFolder`, `CommandSync`, `Plugin`)
#   and automatically registers them if running inside Vagrant.
#

require_relative 'vagrant_freedos/plugin'

Bento::VagrantFreedos::Plugin.register_with_vagrant!
