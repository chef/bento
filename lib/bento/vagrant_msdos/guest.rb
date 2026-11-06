# frozen_string_literal: true

# Top-level Bento namespace.
module Bento
  # Vagrant plugin suite for Microsoft MS-DOS guests.
  module VagrantMsdos
    # Detects Microsoft MS-DOS (1.25, 2.0, 4.0) guests over the active communicator
    # and exposes DOS-compatible guest lifecycle capabilities to Vagrant.
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
        status == 0 && output.match?(/MS-DOS|Microsoft|DOS/i)
      end

      #
      # Detects the specific Microsoft MS-DOS version string (`'1.25'`, `'2.0'`, or `'4.0'`)
      # reported by the guest `VER` command.
      #
      # @param [Object] machine The Vagrant machine instance to inspect.
      # @return [String] Detected version (`'1.25'`, `'2.0'`, or `'4.0'`).
      #
      def detect_version(machine)
        output = +''
        machine.communicate.execute('VER', error_check: false) do |type, data|
          output << data.to_s if type == :stdout
        end
        return '1.25' if output.include?('1.25') || output.include?('1.')
        return '2.0' if output.include?('2.0') || output.include?('2.')

        '4.0'
      end

      #
      # Cleanly powers off the MS-DOS virtual machine using `C:\BENTO\SHUTDOWN.COM`
      # (or `C:\SHUTDOWN.COM` on MS-DOS 1.25) with a fallback to `FDAPM.COM POWEROFF`.
      #
      # @param [Object] machine The Vagrant machine instance to halt.
      # @return [Integer] The DOS exit code of the poweroff command.
      #
      def self.halt(machine)
        shutdown_bento = "C:#{BS}BENTO#{BS}SHUTDOWN.COM"
        shutdown_root  = "C:#{BS}SHUTDOWN.COM"
        fdapm          = "C:#{BS}DOS#{BS}FDAPM.COM"
        machine.communicate.execute("IF EXIST #{shutdown_bento} #{shutdown_bento}", error_check: false)
        machine.communicate.execute("IF EXIST #{shutdown_root} #{shutdown_root}", error_check: false)
        machine.communicate.execute("IF EXIST #{fdapm} #{fdapm} POWEROFF", error_check: false)
      end

      #
      # Sets the `HOSTNAME` environment variable in MS-DOS and persists it to `HOST.BAT`.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @param [String] name Desired hostname string.
      # @param [Boolean] flat_root Whether to write to `C:\HOST.BAT` (MS-DOS 1.25) instead of `C:\BENTO\HOST.BAT`.
      # @return [Integer] The DOS exit code of the command.
      #
      def self.change_host_name(machine, name, flat_root: false)
        safe_name = name.to_s.gsub(/[^A-Za-z0-9_-]/, '')[0, 15]
        host_bat = flat_root ? "C:#{BS}HOST.BAT" : "C:#{BS}BENTO#{BS}HOST.BAT"
        machine.communicate.execute("SET HOSTNAME=#{safe_name}", error_check: false)
        machine.communicate.execute("ECHO SET HOSTNAME=#{safe_name}> #{host_bat}", error_check: false)
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

    # Vagrant 2 `:halt` guest capability module for `:msdos`.
    module GuestCapHalt
      # @param [Object] machine The Vagrant machine instance.
      # @return [Integer] DOS exit code.
      def self.halt(machine)
        Guest.halt(machine)
      end
    end

    # Vagrant 2 `:change_host_name` guest capability module for `:msdos`.
    module GuestCapChangeHostName
      # @param [Object] machine The Vagrant machine instance.
      # @param [String] name Desired hostname.
      # @return [Integer] DOS exit code.
      def self.change_host_name(machine, name)
        Guest.change_host_name(machine, name)
      end
    end

    # Vagrant 2 `:mount_shared_folder` guest capability module for `:msdos`.
    module GuestCapMountSharedFolder
      # @param [Object] machine The Vagrant machine instance.
      # @param [String] name Shared folder name or drive.
      # @param [String, nil] _guestpath Guest mount path.
      # @param [Hash, nil] _options Mount options.
      # @return [Boolean] True if the shared drive responds.
      def self.mount_shared_folder(machine, name = 'D:', _guestpath = nil, _options = nil)
        drive = name.to_s.match?(/^[A-Za-z]:$/) ? name.to_s : 'D:'
        Guest.mount_shared_folder(machine, drive)
      end
    end
  end
end
