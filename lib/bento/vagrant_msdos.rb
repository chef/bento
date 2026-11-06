# frozen_string_literal: true

# Main entry point for the Bento Microsoft MS-DOS (1.25, 2.0, 4.0) Vagrant Plugin Suite.
# Loads all components of `Bento::VagrantMsdos` and automatically registers
# them if running inside Vagrant.

require_relative 'vagrant_msdos/plugin'

Bento::VagrantMsdos::Plugin.register_with_vagrant!
