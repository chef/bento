# frozen_string_literal: true

require 'socket'
require 'securerandom'
require 'base64'
require 'timeout'
require 'fileutils'

# Top-level Bento namespace.
module Bento
  # Vagrant plugin suite for Microsoft MS-DOS guests.
  module VagrantMsdos
    # Exception raised when an MS-DOS command fails or serial communication times out.
    class CommunicatorError < StandardError; end

    # Provides reliable command execution, exit-code (`%ERRORLEVEL%` and
    # MS-DOS 1.25/2.0 fallback error detection) capture, and binary file
    # upload/download between Vagrant and an MS-DOS (1.25, 2.0, 4.0) guest
    # over Telnet or Unix domain serial sockets.
    class Communicator
      # @return [Integer] Telnet Interpret As Command (IAC) byte (255).
      IAC = 255
      # @return [Integer] Telnet WILL negotiation byte (251).
      WILL = 251
      # @return [Integer] Telnet refuse option negotiation byte (252).
      NEG_REFUSE = 252
      # @return [Integer] Telnet DO_OPT negotiation byte (253).
      DO_OPT = 253
      # @return [Integer] Telnet deny option negotiation byte (254).
      NEG_DENY = 254
      # @return [String] Backslash character.
      BS = 92.chr
      # @return [String] Carriage return character.
      CR = 13.chr
      # @return [String] Line feed character.
      LF = 10.chr
      # @return [String] DOS CRLF line ending.
      CRLF = "#{13.chr}#{10.chr}"

      # @return [Regexp] Pattern matching classic MS-DOS 1.25/2.0/4.0 command failure messages.
      DOS_ERROR_OUTPUT_REGEX = /Bad command or file name|Syntax error|File not found|Invalid directory/i

      # @return [Object] The Vagrant machine instance associated with this communicator.
      attr_reader :machine

      #
      # Determines whether this communicator matches the given Vagrant machine.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @return [Boolean] True when the machine uses this DOS communicator or guest.
      #
      def self.match?(machine)
        CommandSsh.msdos_machine?(machine)
      end

      #
      # Initializes a new MS-DOS Communicator for the given Vagrant machine.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @return [Communicator] New communicator instance.
      #
      def initialize(machine)
        @machine = machine
        @socket  = nil
      end

      #
      # Returns the finalized `config.msdos` configuration object for the machine.
      #
      # @return [Bento::VagrantMsdos::Config] Resolved MS-DOS configuration.
      #
      def msdos_config
        if @machine.respond_to?(:config) && @machine.config.respond_to?(:msdos)
          cfg = @machine.config.msdos
          cfg.finalize! if cfg.respond_to?(:finalize!) && cfg.host == Config::UNSET_VALUE
          cfg
        else
          cfg = Config.new
          cfg.finalize!
          cfg
        end
      end

      #
      # Checks whether the MS-DOS guest `COMMAND.COM` is responsive over the serial/telnet channel.
      #
      # @return [Boolean] True if the guest responds to a ping probe within the timeout.
      #
      def ready?
        output = +''
        code = execute('ECHO ===VAGRANT_PING===', error_check: false, timeout: 5) do |_type, data|
          output << data
        end
        code == 0 && output.include?('===VAGRANT_PING===')
      rescue StandardError
        false
      end

      #
      # Waits up to `timeout` seconds for the MS-DOS guest to become ready.
      #
      # @param [Numeric] timeout Maximum seconds to wait for readiness.
      # @return [Boolean] True if the guest became ready before timeout expired, false otherwise.
      #
      def wait_for_ready(timeout)
        deadline = Time.now + timeout.to_f
        loop do
          return true if ready?
          return false if Time.now >= deadline

          sleep(0.05)
        end
      end

      #
      # Resets the underlying Telnet/Unix socket connection to MS-DOS.
      #
      # @return [void]
      #
      def reset!
        close_socket
        open_socket
        nil
      end

      #
      # Executes a DOS command inside the MS-DOS guest and streams output to an optional block.
      #
      # @param [String] command The DOS command or batch line to execute.
      # @param [Hash, nil] opts Execution options (`:error_check`, `:error_class`, `:timeout`).
      # @yield [type, data] Yields `:stdout` or `:stderr` and output lines as they arrive.
      # @yieldparam [Symbol] type Stream identifier (`:stdout` or `:stderr`).
      # @yieldparam [String] data Output text chunk.
      # @return [Integer] The DOS `%ERRORLEVEL%` exit status of the command.
      # @raise [CommunicatorError] If the command returns a non-zero exit code and `:error_check` is enabled.
      #
      def execute(command, opts = nil, &block)
        opts ||= {}
        error_check = opts.fetch(:error_check, true)
        error_class = opts.fetch(:error_class, CommunicatorError)
        timeout_sec = opts.fetch(:timeout, msdos_config.command_timeout)

        req_id = SecureRandom.hex(4).upcase
        start_marker = "===START_#{req_id}==="
        exit_prefix  = "===EXIT_#{req_id}:"

        sock = open_socket
        payload = "ECHO #{start_marker}#{CRLF}#{command}#{CRLF}ECHO #{exit_prefix}%ERRORLEVEL%===#{CRLF}"
        sock.write(payload)
        sock.flush

        captured_lines, exit_code = read_framed_response(sock, start_marker, exit_prefix, timeout_sec, command)
        captured_lines.each do |line|
          block.call(:stdout, "#{line}#{LF}") if block
        end

        if error_check && exit_code != 0
          raise error_class, "MS-DOS command '#{command}' failed with ERRORLEVEL #{exit_code}"
        end

        exit_code
      end

      #
      # Executes an elevated command in MS-DOS (alias for `execute` since DOS is single-user ring-0).
      #
      # @param [String] command The DOS command to execute.
      # @param [Hash, nil] opts Execution options.
      # @yield [type, data] Optional output streaming block.
      # @return [Integer] The DOS `%ERRORLEVEL%` exit status.
      #
      def sudo(command, opts = nil, &block)
        execute(command, opts, &block)
      end

      #
      # Tests a condition inside the MS-DOS guest and returns a boolean result.
      #
      # @param [String] command The DOS command to test.
      # @param [Hash, nil] opts Optional execution options.
      # @return [Boolean] True if the DOS command exits with `%ERRORLEVEL% == 0`, false otherwise.
      #
      def test(command, opts = nil)
        merged_opts = (opts || {}).merge(error_check: false)
        execute(command, merged_opts) == 0
      rescue StandardError
        false
      end

      #
      # Uploads a file or directory from the host into the MS-DOS guest.
      #
      # @param [String] from Host source file or directory path.
      # @param [String] to Guest destination DOS path.
      # @return [Boolean] True on successful upload.
      # @raise [CommunicatorError] If the source path does not exist on the host.
      #
      def upload(from, to)
        raise CommunicatorError, "Host source path does not exist: #{from}" unless File.exist?(from)

        if File.directory?(from)
          upload_directory(from, to)
        else
          upload_file(from, to)
        end
        true
      end

      #
      # Downloads a file from the MS-DOS guest to the host over the serial/telnet channel.
      #
      # @param [String] from Guest source DOS path.
      # @param [String] to Host destination file path.
      # @return [Boolean] True on successful download.
      #
      def download(from, to)
        dos_path = normalize_dos_path(from)
        raw_output = +''
        b64enc_cmd = msdos_config.supports_subdirectories? ? "C:#{BS}BENTO#{BS}B64ENC.COM" : "C:#{BS}B64ENC.COM"
        execute("#{b64enc_cmd} #{dos_path}", error_check: true) do |_type, data|
          raw_output << data
        end

        b64_payload = extract_b64_payload(raw_output)
        decoded = b64_payload.empty? ? raw_output.chomp(LF) : Base64.decode64(b64_payload)
        FileUtils.mkdir_p(File.dirname(to))
        File.binwrite(to, decoded)
        true
      end

      #
      # Strips Telnet IAC (0xFF) negotiation sequences from a raw byte buffer and replies NEG_REFUSE/NEG_DENY.
      #
      # @param [String] data Raw byte string received from socket.
      # @param [IO, nil] sock Optional socket to write NEG_REFUSE/NEG_DENY replies to.
      # @return [String] Clean ASCII/CP437 text with Telnet IAC triplets removed.
      #
      def strip_telnet_iac(data, sock = nil)
        bytes = data.bytes
        clean = []
        i = 0
        while i < bytes.length
          if bytes[i] == IAC
            if i + 1 < bytes.length && bytes[i + 1] == IAC
              clean << IAC
              i += 2
            elsif i + 2 < bytes.length
              cmd = bytes[i + 1]
              opt = bytes[i + 2]
              if sock
                if cmd == DO_OPT
                  sock.write([IAC, NEG_REFUSE, opt].pack('C*'))
                elsif cmd == WILL
                  sock.write([IAC, NEG_DENY, opt].pack('C*'))
                end
              end
              i += 3
            else
              i += 1
            end
          else
            clean << bytes[i]
            i += 1
          end
        end
        clean.pack('C*')
      end

      #
      # Normalizes a path string into a DOS backslash path. When `supports_subdirectories?`
      # is false (MS-DOS 1.25), flattens nested segments onto the root of the target drive.
      #
      # @param [String] path Input POSIX or DOS path.
      # @return [String] Normalized DOS path with backslashes.
      #
      def normalize_dos_path(path)
        str = path.to_s.tr('/', BS)
        vagrant_prefix = "#{BS}vagrant"
        if str.start_with?(vagrant_prefix)
          drive = msdos_config.sync_drive
          str = str.sub(vagrant_prefix, drive)
          str = "#{drive}#{BS}" if str == drive
        end

        if !msdos_config.supports_subdirectories? && str.match?(/^[A-Za-z]:#{Regexp.escape(BS)}.+#{Regexp.escape(BS)}/)
          drive_prefix = str[0, 3]
          leaf_name = str.split(BS).last
          str = "#{drive_prefix}#{leaf_name}"
        end
        str
      end

      private

      #
      # Opens or returns the active TCP Telnet socket or Unix domain serial socket.
      #
      # @return [IO] Connected socket object.
      #
      def open_socket
        return @socket if @socket && !@socket.closed?

        cfg = msdos_config
        @socket = if cfg.transport == :unix_socket && cfg.serial_socket
                    UNIXSocket.new(cfg.serial_socket)
                  else
                    TCPSocket.new(cfg.host, cfg.port)
                  end
      end

      #
      # Closes the active socket connection if open.
      #
      # @return [void]
      #
      def close_socket
        return unless @socket

        @socket.close unless @socket.closed?
        @socket = nil
      end

      #
      # Reads from the socket until the matching `===START_<id>===` and `===EXIT_<id>:<code>===`
      # framing markers are observed. Supports both integer `%ERRORLEVEL%` (MS-DOS 4.0) and
      # unexpanded `%ERRORLEVEL%` (MS-DOS 1.25 / 2.0) by inspecting captured output lines.
      #
      # @param [IO] sock Connected socket.
      # @param [String] start_marker Start sentinel line.
      # @param [String] exit_prefix Exit sentinel prefix.
      # @param [Numeric] timeout_sec Maximum seconds to wait.
      # @param [String] command The original command sent, so its echoed line can be skipped.
      # @return [Array(Array<String>, Integer)] Captured output lines and parsed integer exit code.
      # @raise [CommunicatorError] If the socket closes prematurely or times out.
      #
      def read_framed_response(sock, start_marker, exit_prefix, timeout_sec, command = '')
        buffer = +''
        exit_regex = Regexp.new("#{Regexp.escape(exit_prefix)}([0-9]+|%ERRORLEVEL%|)===")
        Timeout.timeout(timeout_sec, CommunicatorError, "Timed out waiting for MS-DOS response (#{timeout_sec}s)") do
          loop do
            chunk = sock.readpartial(4096)
            buffer << strip_telnet_iac(chunk, sock)
            exit_match = buffer.match(exit_regex)
            if exit_match
              raw_code = exit_match[1]
              lines = extract_between_markers(buffer, start_marker, exit_prefix, command)
              exit_code = resolve_exit_code(raw_code, lines)
              return [lines, exit_code]
            end
          end
        end
      rescue EOFError
        raise CommunicatorError, 'Connection closed by MS-DOS serial/telnet bridge before command completed.'
      end

      #
      # Resolves the integer exit code from either an expanded numeric `%ERRORLEVEL%`
      # or fallback inspection of MS-DOS 1.25/2.0 error output lines.
      #
      # @param [String] raw_code Captured code string from the exit sentinel.
      # @param [Array<String>] lines Captured output lines from the command.
      # @return [Integer] Resolved DOS exit status.
      #
      def resolve_exit_code(raw_code, lines)
        return raw_code.to_i if raw_code.match?(/\A[0-9]+\z/)

        lines.any? { |line| line.match?(DOS_ERROR_OUTPUT_REGEX) } ? 1 : 0
      end

      #
      # Extracts clean output lines between the start sentinel and exit sentinel,
      # ignoring echoed command lines and DOS prompts (`C:\>` or `C>`).
      #
      # @param [String] buffer Raw accumulated output text.
      # @param [String] start_marker Start sentinel string.
      # @param [String] exit_prefix Exit sentinel prefix string.
      # @param [String] command The original command string sent.
      # @return [Array<String>] Filtered output lines.
      #
      def extract_between_markers(buffer, start_marker, exit_prefix, command = '')
        normalized = buffer.gsub(CRLF, LF).tr(CR, LF)
        lines = normalized.split(LF)
        started = false
        collected = []
        prompt_strip = Regexp.new("^[A-Za-z](?::#{Regexp.escape(BS)}[^>]*|:?)>[ ]*")

        lines.each do |line|
          next if line.include?("ECHO #{start_marker}") || line.include?("ECHO #{exit_prefix}")

          if !started
            started = true if line.include?(start_marker)
            next
          end

          break if line.include?(exit_prefix)

          stripped = line.sub(prompt_strip, '')
          next if !command.to_s.empty? && stripped == command.to_s

          collected << stripped
        end
        collected
      end

      #
      # Uploads a single file to the MS-DOS guest in Base64 chunks.
      #
      # @param [String] from Host file path.
      # @param [String] to Guest DOS file path.
      # @return [void]
      #
      def upload_file(from, to)
        dos_dest = normalize_dos_path(to)
        content = File.binread(from)
        encoded = Base64.strict_encode64(content)
        has_subdirs = msdos_config.supports_subdirectories?
        tmp_b64 = has_subdirs ? "C:#{BS}TEMP#{BS}VAGUP.B64" : "C:#{BS}VAGUP.B64"
        b64dec_cmd = has_subdirs ? "C:#{BS}BENTO#{BS}B64DEC.COM" : "C:#{BS}B64DEC.COM"

        execute("IF EXIST #{tmp_b64} DEL #{tmp_b64}", error_check: false)
        encoded.scan(/.{1,64}/).each do |chunk|
          execute("ECHO #{chunk}>> #{tmp_b64}", error_check: true)
        end
        execute("#{b64dec_cmd} #{tmp_b64} #{dos_dest}", error_check: true)
      end

      #
      # Recursively uploads a host directory to the MS-DOS guest.
      #
      # @param [String] from Host directory path.
      # @param [String] to Guest DOS directory path.
      # @return [void]
      #
      def upload_directory(from, to)
        dos_root = normalize_dos_path(to)
        if msdos_config.supports_subdirectories?
          execute("IF NOT EXIST #{dos_root} MKDIR #{dos_root}", error_check: false)
        end
        Dir.children(from).sort.each do |entry|
          src_path = File.join(from, entry)
          clean_root = dos_root.end_with?(BS) ? dos_root.chop : dos_root
          dst_path = "#{clean_root}#{BS}#{entry}"
          if File.directory?(src_path)
            upload_directory(src_path, dst_path)
          else
            upload_file(src_path, dst_path)
          end
        end
      end

      #
      # Extracts Base64 data enclosed between `===B64_START===` and `===B64_END===` markers if present.
      #
      # @param [String] text Raw command output.
      # @return [String] Extracted Base64 string, or empty string if markers are not present.
      #
      def extract_b64_payload(text)
        match = text.match(/===B64_START===[[:space:]]*(.*?)[[:space:]]*===B64_END===/m)
        match ? match[1].gsub(/[[:space:]]+/, '') : ''
      end
    end
  end
end
