# frozen_string_literal: true

#
# @file config.rb
# @brief Configuration class for the Bento FreeDOS Vagrant plugin (`config.freedos`)
# @description
#   Defines all tunable settings for communicating with and synchronizing files
#   to/from a standalone FreeDOS virtual machine over Telnet or Unix domain
#   serial sockets.
#

module Bento
  module VagrantFreedos
    #
    # @class Config
    # @description
    #   Holds configuration attributes for the FreeDOS communicator, `vagrant ssh`
    #   polyfill, and bidirectional folder synchronization (`:freedos_sync`).
    #
    class Config
      # @return [Symbol] Sentinel value representing an unset configuration attribute.
      UNSET_VALUE = :__unset__
      # @return [String] Backslash character.
      BS = 92.chr

      # @return [String, Symbol] Hostname or IP address of the Telnet serial bridge.
      attr_accessor :host

      # @return [Integer, Symbol] TCP port of the Telnet serial bridge.
      attr_accessor :port

      # @return [String, nil, Symbol] Optional Unix domain socket path for COM1 serial.
      attr_accessor :serial_socket

      # @return [Symbol] Transport protocol (`:telnet` or `:unix_socket`).
      attr_accessor :transport

      # @return [Integer, Symbol] Serial port baud rate configured in FreeDOS.
      attr_accessor :baud_rate

      # @return [Integer, Symbol] Maximum time in seconds to wait for FreeDOS boot readiness.
      attr_accessor :boot_timeout

      # @return [Integer, Symbol] Maximum time in seconds to wait for a single DOS command.
      attr_accessor :command_timeout

      # @return [Regexp, Symbol] Regular expression matching the FreeDOS command prompt.
      attr_accessor :prompt_regex

      # @return [String, Symbol] DOS drive letter assigned to the synced folder disk.
      attr_accessor :sync_drive

      # @return [String, Symbol] Default working directory inside FreeDOS.
      attr_accessor :work_dir

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
      end

      #
      # Resolves unset attributes to their default values.
      #
      # @return [void]
      #
      def finalize!
        @host            = '127.0.0.1' if @host == UNSET_VALUE
        @port            = 2323 if @port == UNSET_VALUE
        @serial_socket   = nil if @serial_socket == UNSET_VALUE
        @transport       = :telnet if @transport == UNSET_VALUE
        @baud_rate       = 115_200 if @baud_rate == UNSET_VALUE
        @boot_timeout    = 60 if @boot_timeout == UNSET_VALUE
        @command_timeout = 300 if @command_timeout == UNSET_VALUE
        @prompt_regex    = Regexp.new("[A-Z]:#{Regexp.escape(BS)}[^>]*>", Regexp::IGNORECASE) if @prompt_regex == UNSET_VALUE
        @sync_drive      = 'D:' if @sync_drive == UNSET_VALUE
        @work_dir        = "D:#{BS}" if @work_dir == UNSET_VALUE
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
        { 'freedos' => errors }
      end
    end
  end
end
