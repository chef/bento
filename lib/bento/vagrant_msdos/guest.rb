# frozen_string_literal: true

#
# @file guest.rb
# @brief Vagrant guest OS plugin and capabilities for Microsoft MS-DOS (`config.vm.guest = :msdos`)
# @description
#   Implements MS-DOS (1.25, 2.0, and 4.0) guest detection (`VER` output
#   inspection), version parsing (`detect_version`), and guest capabilities
#   including clean APM/ACPI poweroff (`SHUTDOWN.COM` / `FDAPM.COM`), hostname
#   assignment (`SET HOSTNAME=...`), and shared drive verification.
#

module Bento
  module VagrantMsdos
    #
    # @class Guest
    # @description
    #   Detects MS-DOS (1.25, 2.0, 4.0) guests over the active communicator and
    #   exposes DOS-compatible guest lifecycle capabilities to Vagrant.
    #
    class Guest
      # @return [String] Backslash character.
      BS = 92.chr

      #
      # Checks whether the target Vagrant machine is running Microsoft MS-DOS or compatible DOS.
      #
      # @param [Object] machine The Vagrant machine instance to inspect.
      # @return [Boolean] True if the guest responds with MS-DOS or DOS version output.
      #
      def detect?(machine)
        output = +''
        status = machine.communicate.execute('VER', error_check: false) do |type, data|
          output << data.to_s if type == :stdout
        end
        status == 0 && output.match?(/MS-DOS|Microsoft|FreeDOS|DOS/i)
      end

      #
      # Detects the running MS-DOS version (`"1.25"`, `"2.0"`, or `"4.0"`) from `VER` output.
      #
      # @param [Object] machine The Vagrant machine instance to inspect.
      # @return [String] Detected version string (`"1.25"`, `"2.0"`, or `"4.0"`).
      #
      def detect_version(machine)
        output = +''
        machine.communicate.execute('VER', error_check: false) do |type, data|
          output << data.to_s if type == :stdout
        end
        if output.include?('1.25')
          '1.25'
        elsif output.match?(/2\.00|2\.0\b/)
          '2.0'
        else
          '4.0'
        end
      end

      #
      # Cleanly powers off the MS-DOS virtual machine using `C:\BENTO\SHUTDOWN.COM`
      # (with fallback to `C:\SHUTDOWN.COM` on MS-DOS 1.25 and `C:\FDOS\BIN\FDAPM.COM POWEROFF`).
      #
      # @param [Object] machine The Vagrant machine instance to halt.
      # @return [Integer] The DOS exit code of the poweroff command.
      #
      def self.halt(machine)
        bento_shutdown = "C:#{BS}BENTO#{BS}SHUTDOWN.COM"
        root_shutdown  = "C:#{BS}SHUTDOWN.COM"
        fdapm          = "C:#{BS}FDOS#{BS}BIN#{BS}FDAPM.COM"
        machine.communicate.execute(
          "IF EXIST #{bento_shutdown} #{bento_shutdown} && IF EXIST #{root_shutdown} #{root_shutdown} && IF EXIST #{fdapm} #{fdapm} POWEROFF",
          error_check: false
        )
      end

      #
      # Sets the `HOSTNAME` environment variable in MS-DOS and persists it to `C:\BENTO\HOST.BAT`
      # (or `C:\HOST.BAT` when running MS-DOS 1.25 flat root layout).
      #
      # @param [Object] machine The Vagrant machine instance.
      # @param [String] name Desired hostname string.
      # @param [Boolean] flat_root Whether to write to `C:\HOST.BAT` directly (for MS-DOS 1.25).
      # @return [Integer] The DOS exit code of the command.
      #
      def self.change_host_name(machine, name, flat_root: false)
        safe_name = name.to_s.gsub(/[^A-Za-z0-9_-]/, '')[0, 15]
        host_bat = flat_root ? "C:#{BS}HOST.BAT" : "C:#{BS}BENTO#{BS}HOST.BAT"
        machine.communicate.execute(
          "SET HOSTNAME=#{safe_name} && ECHO SET HOSTNAME=#{safe_name}> #{host_bat}",
          error_check: false
        )
      end

      #
      # Verifies that the configured MS-DOS synced folder drive (e.g. `D:`) is accessible.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @param [String] drive The DOS drive letter to check (default `'D:'`).
      # @return [Boolean] True if the drive exists and responds to `DIR`.
      #
      def self.mount_shared_folder(machine, drive = 'D:')
        machine.communicate.test("DIR #{drive}#{BS} > NUL")
      end
    end
  end
end
