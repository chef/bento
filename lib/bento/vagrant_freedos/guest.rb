# frozen_string_literal: true

# Top-level Bento namespace.
module Bento
  # Vagrant plugin suite for FreeDOS guests.
  module VagrantFreedos
    # Detects FreeDOS / MS-DOS guests over the active communicator and exposes
    # DOS-compatible guest lifecycle capabilities to Vagrant.
    class Guest
      # @return [String] Backslash character.
      BS = 92.chr

      #
      # Checks whether the target Vagrant machine is running FreeDOS or DOS.
      #
      # @param [Object] machine The Vagrant machine instance to inspect.
      # @return [Boolean] True if the guest responds with FreeDOS or DOS version output.
      #
      def detect?(machine)
        output = +''
        status = machine.communicate.execute('VER', error_check: false) do |type, data|
          output << data.to_s if type == :stdout
        end
        status == 0 && output.match?(/FreeDOS|MS-DOS|DOS/i)
      end

      #
      # Cleanly powers off the FreeDOS virtual machine using `FDAPM POWEROFF`
      # with a fallback to `C:\BENTO\SHUTDOWN.COM`.
      #
      # @param [Object] machine The Vagrant machine instance to halt.
      # @return [Integer] The DOS exit code of the poweroff command.
      #
      def self.halt(machine)
        fdapm = "C:#{BS}FDOS#{BS}BIN#{BS}FDAPM.COM"
        shutdown_com = "C:#{BS}BENTO#{BS}SHUTDOWN.COM"
        machine.communicate.execute(
          "IF EXIST #{fdapm} #{fdapm} POWEROFF && IF EXIST #{shutdown_com} #{shutdown_com}",
          error_check: false
        )
      end

      #
      # Sets the `HOSTNAME` environment variable in FreeDOS and persists it to `C:\BENTO\HOST.BAT`.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @param [String] name Desired hostname string.
      # @return [Integer] The DOS exit code of the command.
      #
      def self.change_host_name(machine, name)
        safe_name = name.to_s.gsub(/[^A-Za-z0-9_-]/, '')[0, 15]
        host_bat = "C:#{BS}BENTO#{BS}HOST.BAT"
        machine.communicate.execute(
          "SET HOSTNAME=#{safe_name} && ECHO SET HOSTNAME=#{safe_name}> #{host_bat}",
          error_check: false
        )
      end

      #
      # Verifies that the configured FreeDOS synced folder drive (e.g. `D:`) is accessible.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @param [String] drive The DOS drive letter to check (default `'D:'`).
      # @return [Boolean] True if the drive exists and responds to `DIR`.
      #
      def self.mount_shared_folder(machine, drive = 'D:')
        machine.communicate.test("DIR #{drive}#{BS} > NUL")
      end
    end

    # Vagrant 2 `:halt` guest capability module for `:freedos`.
    module GuestCapHalt
      # @param [Object] machine The Vagrant machine instance.
      # @return [Integer] DOS exit code.
      def self.halt(machine)
        Guest.halt(machine)
      end
    end

    # Vagrant 2 `:change_host_name` guest capability module for `:freedos`.
    module GuestCapChangeHostName
      # @param [Object] machine The Vagrant machine instance.
      # @param [String] name Desired hostname.
      # @return [Integer] DOS exit code.
      def self.change_host_name(machine, name)
        Guest.change_host_name(machine, name)
      end
    end

    # Vagrant 2 `:mount_shared_folder` guest capability module for `:freedos`.
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
