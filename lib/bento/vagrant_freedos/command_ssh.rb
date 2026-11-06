# frozen_string_literal: true

require 'io/console'
require 'socket'

# Top-level Bento namespace.
module Bento
  # Vagrant plugin suite for FreeDOS guests.
  module VagrantFreedos
    # Implements both the Vagrant CLI command plugin interface and the
    # Vagrant Action middleware interface (`#call(env)`) to transparently
    # polyfill `vagrant ssh` and `vagrant ssh -c` for FreeDOS VMs.
    class CommandSsh
      # @return [Integer] ASCII code for `Ctrl+]` (0x1D) escape key to exit interactive console.
      CTRL_RIGHT_BRACKET = 0x1D
      # @return [String] Carriage return character.
      CR = 13.chr
      # @return [String] Line feed character.
      LF = 10.chr
      # @return [String] DOS CRLF line ending.
      CRLF = "#{13.chr}#{10.chr}"

      # @return [Array<String>] Command-line arguments passed to `vagrant ssh`.
      attr_reader :argv

      # @return [Object] The Vagrant environment or next middleware app in the action chain.
      attr_reader :env

      #
      # Returns the short CLI synopsis displayed by `vagrant list-commands`.
      #
      # @return [String] Command synopsis.
      #
      def self.synopsis
        'connects to FreeDOS machine via serial/telnet communicator'
      end

      #
      # Initializes a new `CommandSsh` instance (either as a CLI command or Action middleware).
      #
      # @param [Array<String>, Object] argv_or_app CLI argument array or next middleware callable.
      # @param [Object] env Vagrant environment instance.
      # @return [CommandSsh] New instance.
      #
      def initialize(argv_or_app = [], env = nil)
        if argv_or_app.is_a?(Array)
          @argv = argv_or_app
          @app  = nil
        else
          @argv = []
          @app  = argv_or_app
        end
        @env = env
      end

      #
      # Determines whether a given Vagrant machine is configured as a FreeDOS guest.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @return [Boolean] True if the machine uses the `:freedos` communicator or `:freedos` guest.
      #
      def self.freedos_machine?(machine)
        return false unless machine.respond_to?(:config) && machine.config.respond_to?(:vm)

        vm_cfg = machine.config.vm
        comm = vm_cfg.respond_to?(:communicator) ? vm_cfg.communicator : nil
        guest = vm_cfg.respond_to?(:guest) ? vm_cfg.guest : nil
        %i[freedos freedos_serial freedos_telnet].include?(comm) || guest == :freedos
      end

      #
      # Executes the CLI command when invoked directly by `Vagrant::CLI#execute`.
      # Resolves the target machine from `@env` (or builds a standalone fallback machine)
      # and delegates to `#execute_for_machine`.
      #
      # @param [IO] stdout Output stream (default `$stdout`).
      # @param [IO] stdin Input stream (default `$stdin`).
      # @return [Integer] Exit status code.
      #
      def execute(stdout: $stdout, stdin: $stdin)
        parsed = parse_argv(@argv)
        machine = resolve_target_machine(parsed[:target])
        execute_for_machine(machine, stdout: stdout, stdin: stdin)
      end

      #
      # Parses CLI arguments for `vagrant ssh` / `vagrant freedos-ssh`, extracting
      # `-c <command>` / `--command <command>`, `-p` / `--plain`, and target machine name.
      #
      # @param [Array<String>] args Raw CLI argument strings.
      # @return [Hash<Symbol, Object>] Parsed options hash (`:command`, `:plain`, `:extra_args`, `:target`).
      #
      def parse_argv(args)
        options = { command: nil, plain: false, extra_args: [], target: nil }
        idx = 0
        while idx < args.length
          arg = args[idx]
          case arg
          when '-c', '--command'
            options[:command] = args[idx + 1]
            idx += 2
          when '-p', '--plain'
            options[:plain] = true
            idx += 1
          else
            options[:target] ||= arg unless arg.start_with?('-')
            options[:extra_args] << arg
            idx += 1
          end
        end
        options
      end

      #
      # Vagrant Action middleware entry point (`SSHRun` and `SSHExec` interception).
      # If the target machine is a FreeDOS guest, intercepts the SSH action and routes
      # it over the FreeDOS serial/telnet communicator instead of OpenSSH.
      #
      # @param [Hash] action_env Vagrant action environment hash.
      # @return [Integer, Object] Exit status or result of next middleware.
      #
      def call(action_env)
        machine = action_env[:machine]
        unless self.class.freedos_machine?(machine)
          return @app ? @app.call(action_env) : 0
        end

        cmd = action_env[:ssh_run_command]
        out_io = action_env[:ssh_Polyfill_stdout] || $stdout
        in_io  = action_env[:ssh_Polyfill_stdin] || $stdin

        if cmd
          status = run_single_command(machine, cmd, stdout: out_io)
          action_env[:ssh_run_exit_status] = status
          status
        else
          run_interactive_session(machine, stdout: out_io, stdin: in_io)
        end
      end

      #
      # Executes the CLI command against a specific Vagrant `machine` instance.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @param [IO] stdout Output stream (default `$stdout`).
      # @param [IO] stdin Input stream (default `$stdin`).
      # @return [Integer] Exit code (`0` for interactive session, or DOS `%ERRORLEVEL%` for `-c`).
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
      # Runs a single DOS command (`vagrant ssh -c "<CMD>"`), streams output to `stdout`,
      # triggers post-command Guest-to-Host folder synchronization, and returns the DOS exit code.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @param [String] command The DOS command to execute.
      # @param [IO] stdout Output stream to write command stdout/stderr to.
      # @return [Integer] The DOS `%ERRORLEVEL%` exit status.
      #
      def run_single_command(machine, command, stdout: $stdout)
        comm = machine.communicate
        exit_code = comm.execute(command, error_check: false) do |_type, data|
          stdout.print(data)
          stdout.flush
        end
        SyncedFolder.sync_after_command(machine)
        exit_code
      ensure
        comm.send(:close_socket) if comm.respond_to?(:close_socket, true)
      end

      #
      # Opens an interactive terminal bridge between `stdin`/`stdout` and the FreeDOS
      # COM1 Telnet/Unix socket until `Ctrl+]` (`0x1D`) or EOF is received.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @param [IO] stdout Output stream for guest console characters.
      # @param [IO] stdin Input stream for user keystrokes.
      # @param [IO, nil] socket Optional pre-connected socket (used for testing).
      # @return [Integer] Exit code `0`.
      #
      def run_interactive_session(machine, stdout: $stdout, stdin: $stdin, socket: nil)
        sock = socket || open_interactive_socket(machine)
        stdout.puts("Connected to FreeDOS (COM1 Serial/Telnet Polyfill). Press Ctrl+] or type 'EXIT' to disconnect.")
        sock.write(CRLF)
        sock.flush

        pump_interactive_streams(sock, stdin, stdout)
        SyncedFolder.sync_after_command(machine)
        0
      ensure
        sock.close if socket.nil? && sock && !sock.closed?
      end

      private

      #
      # Resolves the target Vagrant machine from `@env` or constructs a standalone fallback machine.
      #
      # @param [String, nil] target_name Optional target machine name from CLI args.
      # @return [Object] Vagrant machine or standalone compatible machine struct.
      #
      def resolve_target_machine(target_name)
        if @env && @env.respond_to?(:machine) && @env.respond_to?(:active_machines)
          active_list = @env.active_machines
          target_sym = target_name&.to_sym
          chosen = (target_sym && active_list.find { |n, _p| n == target_sym }) || active_list.first
          return @env.machine(chosen[0], chosen[1]) if chosen
        end

        cfg = Config.new
        cfg.host = ENV['FREEDOS_SERIAL_HOST'] if ENV['FREEDOS_SERIAL_HOST'] && !ENV['FREEDOS_SERIAL_HOST'].empty?
        cfg.port = ENV['FREEDOS_SERIAL_PORT'].to_i if ENV['FREEDOS_SERIAL_PORT'] && !ENV['FREEDOS_SERIAL_PORT'].empty?
        cfg.finalize!

        vm_s   = Struct.new(:communicator, :guest).new(:freedos, :freedos)
        conf_s = Struct.new(:vm, :freedos).new(vm_s, cfg)
        mach_s = Struct.new(:config, :data_dir, :name).new(conf_s, nil, (target_name || 'default').to_sym)
        comm   = Communicator.new(mach_s)
        mach_s.define_singleton_method(:communicate) { comm }
        mach_s
      end

      #
      # Opens a raw TCP or Unix socket to the FreeDOS guest's serial port for interactive use.
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
      # Bidirectional byte pump between `stdin`, `sock`, and `stdout`.
      #
      # @param [IO] sock Connected guest serial/telnet socket.
      # @param [IO] stdin User input stream.
      # @param [IO] stdout User output stream.
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
