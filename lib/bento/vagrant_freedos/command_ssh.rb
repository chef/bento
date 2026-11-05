# frozen_string_literal: true

#
# @file command_ssh.rb
# @brief Vagrant `ssh` command & action polyfill for FreeDOS (`vagrant ssh` & `vagrant ssh -c "<CMD>"`)
# @description
#   Intercepts `vagrant ssh` and `vagrant ssh -c "<CMD>"` (as well as Vagrant
#   built-in `SSHExec` and `SSHRun` actions) when the target machine uses the
#   `:freedos` communicator or guest type. Routes single-command invocations
#   through the Telnet/Serial communicator (returning the exact DOS `%ERRORLEVEL%`)
#   and routes interactive sessions to a bidirectional raw-TTY console connected
#   to FreeDOS `COM1`.
#

require 'socket'

module Bento
  module VagrantFreedos
    #
    # @class CommandSsh
    # @description
    #   Provides both a CLI command handler and a Vagrant Action middleware for
    #   polyfilling `vagrant ssh` over the FreeDOS Telnet/Serial bridge.
    #
    class CommandSsh
      # @return [Integer] ASCII byte for Ctrl+] (0x1D) disconnect hotkey.
      CTRL_RIGHT_BRACKET = 29
      # @return [String] Carriage return character.
      CR = 13.chr
      # @return [String] Line feed character.
      LF = 10.chr
      # @return [String] DOS CRLF line ending.
      CRLF = "#{13.chr}#{10.chr}"

      # @return [Array<String>] Command-line arguments passed to `vagrant ssh`.
      attr_reader :argv

      # @return [Object] The Vagrant environment or machine context.
      attr_reader :env

      #
      # Initializes the `vagrant ssh` polyfill command or middleware.
      #
      # @param [Array<String>, Object] argv_or_app Either CLI `argv` array or the next middleware `app`.
      # @param [Object] env The Vagrant environment or action `env` hash.
      # @return [CommandSsh] New instance.
      #
      def initialize(argv_or_app, env = nil)
        if argv_or_app.is_a?(Array)
          @argv = argv_or_app
          @env  = env
          @app  = nil
        else
          @app  = argv_or_app
          @env  = env
          @argv = []
        end
      end

      #
      # Checks whether a given Vagrant machine uses the FreeDOS communicator or guest plugin.
      #
      # @param [Object] machine The Vagrant machine instance to inspect.
      # @return [Boolean] True if the machine is configured for FreeDOS.
      #
      def self.freedos_machine?(machine)
        return false unless machine.respond_to?(:config) && machine.config.respond_to?(:vm)

        vm = machine.config.vm
        comm = vm.respond_to?(:communicator) ? vm.communicator : nil
        guest = vm.respond_to?(:guest) ? vm.guest : nil
        %i[freedos freedos_serial freedos_telnet].include?(comm) || guest == :freedos
      end

      #
      # Executes the `vagrant ssh` CLI command for a target machine.
      #
      # @param [Object] machine The target Vagrant machine instance.
      # @param [IO] stdout Output stream for command output (default `$stdout`).
      # @param [IO] stdin Input stream for interactive console (default `$stdin`).
      # @return [Integer] Process exit code (DOS `%ERRORLEVEL%` or `0`).
      #
      def execute_for_machine(machine, stdout: $stdout, stdin: $stdin)
        parsed = parse_argv(@argv)
        if parsed[:command]
          run_single_command(machine, parsed[:command], stdout: stdout)
        else
          run_interactive_session(machine, stdout: stdout, stdin: stdin)
        end
      end

      #
      # Middleware `call` hook compatible with `Vagrant::Action::Builder` stacks
      # (`SSHRun` and `SSHExec` interception).
      #
      # @param [Hash] action_env The Vagrant action environment hash.
      # @return [Object] Result of the middleware chain or FreeDOS polyfill execution.
      #
      def call(action_env)
        machine = action_env[:machine]
        if machine && self.class.freedos_machine?(machine)
          cmd = action_env[:ssh_run_command]
          out_io = action_env[:ssh_Polyfill_stdout] || $stdout
          in_io  = action_env[:ssh_polyfill_stdin] || $stdin
          if cmd
            action_env[:ssh_run_exit_status] = run_single_command(machine, cmd, stdout: out_io)
          else
            action_env[:ssh_run_exit_status] = run_interactive_session(machine, stdout: out_io, stdin: in_io)
          end
          return action_env[:ssh_run_exit_status]
        end

        @app ? @app.call(action_env) : 0
      end

      #
      # Executes a single DOS command via `vagrant ssh -c "<CMD>"` and streams output.
      # Triggers post-command Guest-to-Host folder synchronization if configured.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @param [String] command The DOS command to run.
      # @param [IO] stdout Output stream to write guest stdout/stderr to.
      # @return [Integer] The integer DOS `%ERRORLEVEL%` returned by the command.
      #
      def run_single_command(machine, command, stdout: $stdout)
        exit_code = machine.communicate.execute(command, error_check: false) do |_type, data|
          stdout.print(data)
          stdout.flush
        end
        if machine.respond_to?(:data_dir) && machine.data_dir
          SyncedFolder.sync_after_command(machine)
        end
        exit_code
      end

      #
      # Runs an interactive raw-TTY terminal session bridged to FreeDOS `COM1` (`C:\>`).
      # Disconnects cleanly when the user presses `Ctrl+]` (`0x1D`) or when the socket closes.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @param [IO] stdout Host output stream.
      # @param [IO] stdin Host input stream.
      # @param [IO, nil] socket Optional pre-connected socket (for testing or custom transport).
      # @return [Integer] Returns `0` on clean session disconnect.
      #
      def run_interactive_session(machine, stdout: $stdout, stdin: $stdin, socket: nil)
        sock = socket || open_interactive_socket(machine)
        stdout.puts("Connected to FreeDOS (COM1 Serial/Telnet Polyfill). Press Ctrl+] or type 'EXIT' to disconnect.")
        sock.write(CRLF)

        pump_interactive_streams(sock, stdin, stdout)
        0
      ensure
        sock.close if socket.nil? && sock && !sock.closed?
      end

      #
      # Parses CLI arguments passed to `vagrant ssh` (`-c` / `--command`).
      #
      # @param [Array<String>] args Raw argument list.
      # @return [Hash<Symbol, Object>] Parsed options hash (`:command`, `:plain`).
      #
      def parse_argv(args)
        result = { command: nil, plain: false }
        idx = 0
        while idx < args.length
          arg = args[idx]
          if ['-c', '--command'].include?(arg)
            result[:command] = args[idx + 1]
            idx += 2
          elsif arg == '-p' || arg == '--plain'
            result[:plain] = true
            idx += 1
          else
            idx += 1
          end
        end
        result
      end

      private

      #
      # Opens a new TCP Telnet or Unix domain socket to the FreeDOS serial port.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @return [IO] Connected socket.
      #
      def open_interactive_socket(machine)
        comm = Communicator.new(machine)
        cfg = comm.freedos_config
        if cfg.transport == :unix_socket && cfg.serial_socket
          UNIXSocket.new(cfg.serial_socket)
        else
          TCPSocket.new(cfg.host, cfg.port)
        end
      end

      #
      # Relays bytes bidirectionally between `stdin`/`stdout` and the FreeDOS serial socket
      # until `Ctrl+]` (`0x1D`) is pressed or EOF is reached on either stream.
      #
      # @param [IO] sock Connected serial/telnet socket.
      # @param [IO] stdin Host standard input stream.
      # @param [IO] stdout Host standard output stream.
      # @return [void]
      #
      def pump_interactive_streams(sock, stdin, stdout)
        iac_filter = Communicator.new(nil)
        select_timeout = stdin.respond_to?(:tty?) && stdin.tty? ? nil : 5.0
        loop do
          ready_ios, = IO.select([sock, stdin], nil, nil, select_timeout)
          break unless ready_ios

          if ready_ios.include?(sock)
            break if sock.eof?

            data = sock.readpartial(1024)
            clean = iac_filter.strip_telnet_iac(data, sock)
            stdout.print(clean)
            stdout.flush
          end

          if ready_ios.include?(stdin)
            break if stdin.eof?

            input = stdin.readpartial(1024)
            break if input.bytes.include?(CTRL_RIGHT_BRACKET)

            translated = input.gsub(CRLF, LF).gsub(LF, CRLF)
            sock.write(translated)
            sock.flush
          end
        end
      rescue EOFError, IOError
        nil
      end
    end
  end
end
