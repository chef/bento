# frozen_string_literal: true

# Top-level Bento namespace.
module Bento
  # Vagrant plugin suite for Microsoft MS-DOS guests.
  module VagrantMsdos
    # CLI handler for `vagrant msdos-sync` to push host files to MS-DOS (`--to-guest`),
    # pull guest build/test artifacts back to the host (`--to-host`), or run a watch cycle.
    class CommandSync
      # @return [Array<String>] Command-line arguments passed to `vagrant msdos-sync`.
      attr_reader :argv

      # @return [Object] The Vagrant environment context.
      attr_reader :env

      #
      # Returns the short CLI synopsis displayed by `vagrant list-commands`.
      #
      # @return [String] Command synopsis.
      #
      def self.synopsis
        'synchronizes files between host and MS-DOS guest drive'
      end

      #
      # Initializes a new `CommandSync` CLI handler.
      #
      # @param [Array<String>] argv Command-line argument list.
      # @param [Object] env Vagrant environment instance.
      # @return [CommandSync] New command instance.
      #
      def initialize(argv, env = nil)
        @argv = argv
        @env  = env
      end

      #
      # Executes the CLI command when invoked directly by `Vagrant::CLI#execute`.
      #
      # @param [String] host_dir Host workspace directory to sync (default `Dir.pwd`).
      # @param [IO] stdout Output stream for status messages (default `$stdout`).
      # @return [Integer] Exit status (`0` on success).
      #
      def execute(host_dir: Dir.pwd, stdout: $stdout)
        opts = parse_argv(@argv)
        machine = resolve_target_machine(opts[:target])
        execute_for_machine(machine, host_dir: host_dir, stdout: stdout)
      end

      #
      # Executes the synchronization operation against `machine`.
      #
      # @param [Object] machine The target Vagrant machine instance.
      # @param [String] host_dir Host workspace directory to sync (default `Dir.pwd`).
      # @param [IO] stdout Output stream for status messages (default `$stdout`).
      # @return [Integer] Exit status (`0` on success).
      #
      def execute_for_machine(machine, host_dir: Dir.pwd, stdout: $stdout)
        opts = parse_argv(@argv)
        syncer = SyncedFolder.new
        sync_opts = {
          drive: 'D:',
          live_push: opts[:live],
          live_pull: opts[:live],
          crlf_convert: opts[:crlf]
        }

        iterations = opts[:watch] ? opts[:iterations] : 1
        iterations.times do |idx|
          if %i[bidirectional to_guest].include?(opts[:direction])
            pushed = syncer.sync_to_guest(machine, host_dir, sync_opts)
            stdout.puts("Synced #{pushed.size} file(s) to MS-DOS guest.")
          end
          if %i[bidirectional to_host].include?(opts[:direction])
            pulled = syncer.sync_to_host(machine, host_dir, sync_opts)
            stdout.puts("Synced #{pulled.size} file(s) from MS-DOS guest to host.")
          end
          sleep(opts[:interval]) if opts[:watch] && idx + 1 < iterations
        end
        0
      end

      #
      # Parses CLI flags for `vagrant msdos-sync`.
      #
      # @param [Array<String>] args Raw CLI arguments.
      # @return [Hash<Symbol, Object>] Parsed options (`:direction`, `:watch`, `:live`, `:crlf`, `:iterations`, `:interval`, `:target`).
      #
      def parse_argv(args)
        options = {
          direction: :bidirectional,
          watch: false,
          live: false,
          crlf: false,
          iterations: 1,
          interval: 0.05,
          target: nil
        }
        args.each do |arg|
          case arg
          when '--to-guest'
            options[:direction] = :to_guest
          when '--to-host'
            options[:direction] = :to_host
          when '--watch'
            options[:watch] = true
          when '--live'
            options[:live] = true
          when '--crlf'
            options[:crlf] = true
          else
            options[:target] ||= arg unless arg.start_with?('-')
          end
        end
        options
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

        Struct.new(:data_dir).new(nil)
      end
    end
  end
end
