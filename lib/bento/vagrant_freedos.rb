# frozen_string_literal: true

# Main entry point for the Bento FreeDOS Vagrant Plugin Suite.
# Loads all components of `Bento::VagrantFreedos` and automatically registers
# them if running inside Vagrant.

require_relative 'vagrant_freedos/plugin'

Bento::VagrantFreedos::Plugin.register_with_vagrant!
