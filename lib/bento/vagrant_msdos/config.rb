# frozen_string_literal: true

#
# @file config.rb
# @brief Configuration class for the Bento MS-DOS Vagrant plugin (`config.msdos`)
# @description
#   Defines all tunable settings for communicating with and synchronizing files
#   to/from a standalone Microsoft MS-DOS (1.25, 2.0, or 4.0) virtual machine
#   over Telnet or Unix domain serial sockets.
#

module Bento
  module VagrantMsdos
    #
    # @class Config
    # @description
    #   Holds configuration attributes for the MS-DOS communicator, `vagrant ssh`
    #   polyfill, and bidirectional folder synchronization (`:msdos_sync`).
    #
    class Config
      # @return [Symbol] Sentinel value representing an unset configuration attribute.
      UNSET_VALUE = :__unset__
      # @return [String] Backslash character.
      BS = 92.chr
      # @return [Array<String>] Supported Microsoft MS-DOS versions.
      SUPPORTED_VERSIONS = %w[1.25 2.0 4.0 4.00].freeze

      # @return [String, Symbol] Hostname or IP address of the Telnet serial bridge.
      attr_accessor :host

      # @return [Integer, Symbol] TCP port of the Telnet serial bridge.
      attr_accessor :port

      # @return [String, nil, Symbol] Optional Unix domain socket path for COM1 serial.
      attr_accessor :serial_socket

      # @return [Symbol] Transport protocol (`:telnet` or `:unix_socket`).
      attr_accessor :transport

      # @return [Integer, Symbol] Serial port baud rate configured in MS-DOS.
      attr_accessor :baud_rate

      # @return [Integer, Symbol] Maximum time in seconds to wait for MS-DOS boot readiness.
      attr_accessor :boot_timeout

      # @return [Integer, Symbol] Maximum time in seconds to wait for a single DOS command.
      attr_accessor :command_timeout

      # @return [Regexp, Symbol] Regular expression matching the MS-DOS command prompt (`C:\>` or `C>`).
      attr_accessor :prompt_regex

      # @return [String, Symbol] DOS drive letter assigned to the synced folder disk.
      attr_accessor :sync_drive

      # @return [String, Symbol] Default working directory inside MS-DOS.
      attr_accessor :work_dir

      # @return [String, Symbol] Target MS-DOS version (`"1.25"`, `"2.0"`, or `"4.0"`).
      attr_accessor :dos_version

      #
      # Initializes a new Config instance with all attributes set to UNSET_VALUE.
      #
      # @return [Config] New configuration instance.
      #
      def initialize
        @host            = UNSET_VALUE
        @port            = UNSET_VALUE
        @serial_socket   = UNSET_VALUE
        @transport       = UNSET_VALUE
        @baud_rate       = UNSET_VALUE
        @boot_timeout    = UNSET_VALUE
        @command_timeout = UNSET_VALUE
        @prompt_regex    = UNSET_VALUE
        @sync_drive      = UNSET_VALUE
        @work_dir        = UNSET_VALUE
        @dos_version     = UNSET_VALUE
      end

      #
      # Resolves unset attributes to their default values.
      #
      # @return [void]
      #
      def finalize!
        @host            = '127.0.0.1' if @host == UNSET_VALUE
        @port            = 2324 if @port == UNSET_VALUE
        @serial_socket   = nil if @serial_socket == UNSET_VALUE
        @transport       = :telnet if @transport == UNSET_VALUE
        @baud_rate       = 115_200 if @baud_rate == UNSET_VALUE
        @boot_timeout    = 60 if @boot_timeout == UNSET_VALUE
        @command_timeout = 300 if @command_timeout == UNSET_VALUE
        @prompt_regex    = Regexp.new('[A-Z]:?[^>]*>', Regexp::IGNORECASE) if @prompt_regex == UNSET_VALUE
        @sync_drive      = 'D:' if @sync_drive == UNSET_VALUE
        @work_dir        = "D:#{BS}" if @work_dir == UNSET_VALUE
        @dos_version     = '4.0' if @dos_version == UNSET_VALUE
        @dos_version     = '4.0' if @dos_version == '4.00'
      end

      #
      # Returns whether the configured MS-DOS version supports hierarchical subdirectories.
      # MS-DOS 1.25 uses a flat FAT12 directory structure (`false`), whereas MS-DOS 2.0 and 4.0
      # support `MKDIR` / `CHDIR` hierarchical paths (`true`).
      #
      # @return [Boolean] True if subdirectories are supported, false on MS-DOS 1.25.
      #
      def supports_subdirectories?
        finalize! if @dos_version == UNSET_VALUE
        @dos_version != '1.25'
      end

      #
      # Validates configuration settings and returns a hash of errors keyed by section name.
      #
      # @param [Object] _machine The Vagrant machine instance being validated.
      # @return [Hash<String, Array<String>>] Map of component name to validation error messages.
      #
      def validate(_machine)
        errors = []
        unless %i[telnet unix_socket].include?(@transport)
          errors << "Invalid transport #{@transport.inspect}; must be :telnet or :unix_socket."
        end
        if @transport == :telnet && (!@port.is_a?(Integer) || @port <= 0 || @port > 65_535)
          errors << "Invalid port #{@port.inspect}; must be an integer between 1 and 65535."
        end
        if @transport == :unix_socket && (@serial_socket.nil? || @serial_socket.to_s.strip.empty?)
          errors << 'serial_socket path must be provided when transport is :unix_socket.'
        end
        drive_regex = Regexp.new('^[A-Za-z]:$')
        unless @sync_drive.is_a?(String) && @sync_drive.match?(drive_regex)
          errors << "Invalid sync_drive #{@sync_drive.inspect}; must be a drive letter such as 'D:'."
        end
        unless SUPPORTED_VERSIONS.include?(@dos_version.to_s)
          errors << "Invalid dos_version #{@dos_version.inspect}; must be '1.25', '2.0', or '4.0'."
        end
        { 'msdos' => errors }
      end
    end
  end
end
