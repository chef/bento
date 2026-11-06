# frozen_string_literal: true

require 'fileutils'
require 'digest'
require 'json'

# Top-level Bento namespace.
module Bento
  # Vagrant plugin suite for FreeDOS guests.
  module VagrantFreedos
    # Manages bidirectional directory synchronization between a host directory
    # and a FreeDOS guest drive (default `D:`).
    class SyncedFolder
      # @return [String] Backslash character.
      BS = 92.chr
      # @return [String] Carriage return character.
      CR = 13.chr
      # @return [String] Line feed character.
      LF = 10.chr
      # @return [String] DOS CRLF line ending.
      CRLF = "#{13.chr}#{10.chr}"

      # @return [Array<String>] File extensions eligible for automatic LF -> CRLF conversion.
      TEXT_EXTENSIONS = %w[.bat .cmd .c .h .cpp .hpp .asm .inc .wat .mak .lnk .cfg .txt].freeze

      #
      # Initializes internal Vagrant 2 synced folder plugin state.
      #
      # @return [void]
      #
      def _initialize(*_args); end

      #
      # Queries whether a specific synced folder capability is implemented.
      #
      # @param [Symbol, String] _cap_name Capability name.
      # @return [Boolean] Always false for DOS synced folders.
      #
      def capability?(_cap_name)
        false
      end

      #
      # Disables synced folders before removal or teardown.
      #
      # @param [Object] _machine The Vagrant machine instance.
      # @param [Hash] _folders Synced folder map.
      # @param [Hash, nil] _opts Additional options.
      # @return [void]
      #
      def disable(_machine, _folders, _opts = nil); end

      #
      # Determines whether the `:freedos_sync` synced folder plugin is usable for `machine`.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @param [Boolean] _raise_error Whether to raise an exception if unusable.
      # @return [Boolean] True when the machine is configured as a FreeDOS guest.
      #
      def usable?(machine, _raise_error = false)
        CommandSsh.freedos_machine?(machine)
      end

      #
      # Prepares the secondary FAT sync disk image before the VM boots.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @param [Hash<String, Hash>] folders Map of folder IDs to folder option hashes.
      # @param [Hash, nil] _opts Additional provider options.
      # @return [void]
      #
      def prepare(machine, folders, _opts = nil)
        ensure_sync_disk(machine)
        folders.each_value do |folder_opts|
          next if folder_opts[:disabled]

          direction = folder_opts.fetch(:sync_direction, :bidirectional)
          if %i[bidirectional to_guest].include?(direction)
            sync_to_guest(machine, folder_opts[:hostpath], folder_opts)
          end
        end
      end

      #
      # Enables synced folders once the FreeDOS VM has booted and performs live sync if needed.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @param [Hash<String, Hash>] folders Map of folder IDs to folder option hashes.
      # @param [Hash, nil] _opts Additional options.
      # @return [void]
      #
      def enable(machine, folders, _opts = nil)
        save_registered_folders(machine, folders)
        folders.each_value do |folder_opts|
          next if folder_opts[:disabled]

          direction = folder_opts.fetch(:sync_direction, :bidirectional)
          if %i[bidirectional to_guest].include?(direction)
            sync_to_guest(machine, folder_opts[:hostpath], folder_opts)
          end
        end
      end

      #
      # Synchronizes guest artifacts back to the host before VM halt or cleanup.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @param [Hash, nil] _opts Cleanup options.
      # @return [void]
      #
      def cleanup(machine, _opts = nil)
        self.class.sync_after_command(machine)
      end

      #
      # Synchronizes files from `host_dir` on the host into the FreeDOS guest sync drive (`D:`).
      # Updates both the staging/FAT disk image and (if the communicator is ready) pushes
      # changed files live over the communicator.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @param [String] host_dir Host directory path to sync from.
      # @param [Hash] opts Folder synchronization options (`:drive`, `:exclude`, `:crlf_convert`, `:live_push`).
      # @return [Array<String>] List of relative file paths synchronized to the guest.
      #
      def sync_to_guest(machine, host_dir, opts = {})
        return [] unless host_dir && File.directory?(host_dir)

        drive = opts.fetch(:drive, 'D:')
        excludes = Array(opts.fetch(:exclude, ['.git/', '.vagrant/', 'builds/']))
        crlf_convert = opts.fetch(:crlf_convert, false)
        live_push = opts.fetch(:live_push, false)

        stage_dir = guest_stage_dir(machine)
        FileUtils.mkdir_p(stage_dir)
        manifest = load_manifest(machine)
        synced_rel_paths = []

        collect_host_files(host_dir, excludes).each do |rel_path|
          src_file = File.join(host_dir, rel_path)
          raw_bytes = File.binread(src_file)
          payload = crlf_convert && text_file?(rel_path) ? convert_to_crlf(raw_bytes) : raw_bytes
          digest = Digest::SHA256.hexdigest(payload)

          next if manifest[rel_path] == digest

          staged_file = File.join(stage_dir, rel_path)
          FileUtils.mkdir_p(File.dirname(staged_file))
          File.binwrite(staged_file, payload)

          if live_push && machine.respond_to?(:communicate)
            dos_rel = rel_path.tr('/', BS)
            machine.communicate.upload(staged_file, "#{drive}#{BS}#{dos_rel}")
          end

          manifest[rel_path] = digest
          synced_rel_paths << rel_path
        end

        save_manifest(machine, manifest)
        synced_rel_paths
      end

      #
      # Synchronizes newly created or modified files from the FreeDOS guest sync drive (`D:`)
      # back into `host_dir` on the host.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @param [String] host_dir Host destination directory path.
      # @param [Hash] opts Folder synchronization options (`:drive`, `:exclude`, `:live_pull`).
      # @return [Array<String>] List of relative file paths synchronized back to the host.
      #
      def sync_to_host(machine, host_dir, opts = {})
        return [] unless host_dir

        FileUtils.mkdir_p(host_dir)
        drive = opts.fetch(:drive, 'D:')
        excludes = Array(opts.fetch(:exclude, ['.git/', '.vagrant/', 'builds/']))
        live_pull = opts.fetch(:live_pull, false)

        if live_pull && machine.respond_to?(:communicate)
          pull_live_files_to_stage(machine, drive)
        end

        stage_dir = guest_stage_dir(machine)
        return [] unless File.directory?(stage_dir)

        manifest = load_manifest(machine)
        pulled_paths = []

        collect_host_files(stage_dir, excludes).each do |rel_path|
          staged_file = File.join(stage_dir, rel_path)
          dest_file   = File.join(host_dir, rel_path)
          staged_bytes = File.binread(staged_file)
          staged_hash  = Digest::SHA256.hexdigest(staged_bytes)

          host_exists = File.exist?(dest_file)
          host_hash = host_exists ? Digest::SHA256.hexdigest(File.binread(dest_file)) : nil

          next if host_hash == staged_hash

          FileUtils.mkdir_p(File.dirname(dest_file))
          File.binwrite(dest_file, staged_bytes)
          manifest[rel_path] = staged_hash
          pulled_paths << rel_path
        end

        save_manifest(machine, manifest)
        pulled_paths
      end

      #
      # Runs Guest-to-Host synchronization for all bidirectional or `:to_host` folders
      # registered on `machine`. Called automatically after `vagrant ssh -c "<CMD>"` or on halt.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @return [Array<String>] Combined list of relative paths synced back to host.
      #
      def self.sync_after_command(machine)
        syncer = new
        folders = syncer.load_registered_folders(machine)
        pulled = []
        folders.each_value do |folder_opts|
          next if folder_opts[:disabled]

          direction = folder_opts.fetch(:sync_direction, :bidirectional).to_sym
          if %i[bidirectional to_host].include?(direction)
            pulled.concat(syncer.sync_to_host(machine, folder_opts[:hostpath], folder_opts))
          end
        end
        pulled
      end

      #
      # Returns the path to the secondary FAT16/FAT32 disk image (`freedos_sync_d.raw`) for `machine`.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @return [String] Absolute path to the sync disk image.
      #
      def sync_disk_path(machine)
        File.join(machine_data_dir(machine), 'freedos_sync_d.raw')
      end

      #
      # Returns the host staging directory representing the contents of the FreeDOS `D:` drive.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @return [String] Path to the staging directory.
      #
      def guest_stage_dir(machine)
        File.join(machine_data_dir(machine), 'freedos_drive_d')
      end

      #
      # Creates the sparse/raw sync disk file if it does not yet exist.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @param [Integer] size_mb Size of the disk image in megabytes (default `16`).
      # @return [String] Path to the created or existing sync disk image.
      #
      def ensure_sync_disk(machine, size_mb: 16)
        path = sync_disk_path(machine)
        FileUtils.mkdir_p(File.dirname(path))
        unless File.exist?(path)
          File.open(path, 'wb') do |f|
            f.seek((size_mb * 1024 * 1024) - 1)
            f.write("\0")
          end
        end
        path
      end

      #
      # Persists the active synced folder definitions to the machine's data directory.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @param [Hash] folders Synced folders configuration map.
      # @return [void]
      #
      def save_registered_folders(machine, folders)
        path = File.join(machine_data_dir(machine), 'freedos_folders.json')
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, JSON.pretty_generate(folders))
      end

      #
      # Loads previously persisted synced folder definitions from the machine's data directory.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @return [Hash<String, Hash>] Deserialized folder definitions with symbolized option keys.
      #
      def load_registered_folders(machine)
        path = File.join(machine_data_dir(machine), 'freedos_folders.json')
        return {} unless File.exist?(path)

        raw = JSON.parse(File.read(path))
        raw.transform_values do |opts|
          opts.each_with_object({}) { |(k, v), acc| acc[k.to_sym] = v }
        end
      end

      #
      # Converts LF line endings to DOS CRLF without doubling existing CRLF sequences.
      #
      # @param [String] content Input text content.
      # @return [String] CRLF-normalized content.
      #
      def convert_to_crlf(content)
        content.gsub(CRLF, LF).gsub(LF, CRLF)
      end

      private

      #
      # Resolves a writable data directory for storing machine sync state and images.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @return [String] Data directory path.
      #
      def machine_data_dir(machine)
        if machine.respond_to?(:data_dir) && machine.data_dir
          machine.data_dir.to_s
        else
          File.join(Dir.tmpdir, 'bento_vagrant_freedos_default')
        end
      end

      #
      # Checks whether a relative path has a DOS text/source file extension.
      #
      # @param [String] rel_path Relative file path.
      # @return [Boolean] True if the extension is in `TEXT_EXTENSIONS`.
      #
      def text_file?(rel_path)
        TEXT_EXTENSIONS.include?(File.extname(rel_path).downcase)
      end

      #
      # Collects all non-excluded relative file paths within `root_dir`.
      #
      # @param [String] root_dir Root directory to walk.
      # @param [Array<String>] excludes Excluded path prefixes or patterns.
      # @return [Array<String>] Sorted list of relative POSIX file paths.
      #
      def collect_host_files(root_dir, excludes)
        results = []
        Dir.glob('**/*', File::FNM_DOTMATCH, base: root_dir).sort.each do |rel|
          next if rel == '.' || rel == '..' || rel.end_with?('/.') || rel.end_with?('/..')
          next if excluded?(rel, excludes)

          full = File.join(root_dir, rel)
          results << rel if File.file?(full)
        end
        results
      end

      #
      # Determines whether a relative path matches any exclusion pattern.
      #
      # @param [String] rel_path Relative path to check.
      # @param [Array<String>] excludes Exclusion patterns.
      # @return [Boolean] True if excluded.
      #
      def excluded?(rel_path, excludes)
        excludes.any? do |pattern|
          clean = pattern.to_s.sub(%r{/\z}, '')
          rel_path == clean || rel_path.start_with?("#{clean}/") || File.fnmatch?(pattern.to_s, rel_path)
        end
      end

      #
      # Queries `DIR <drive>\ /B` over the communicator and downloads each listed file into the stage directory.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @param [String] drive DOS drive letter (e.g. `'D:'`).
      # @return [void]
      #
      def pull_live_files_to_stage(machine, drive)
        listing = +''
        machine.communicate.execute("DIR #{drive}#{BS} /B", error_check: false) do |_type, data|
          listing << data
        end
        stage_dir = guest_stage_dir(machine)
        FileUtils.mkdir_p(stage_dir)

        listing.split(LF).map(&:strip).reject(&:empty?).each do |entry|
          next if entry.include?(' ')

          machine.communicate.download("#{drive}#{BS}#{entry}", File.join(stage_dir, entry))
        end
      end

      #
      # Loads the SHA-256 sync manifest for `machine`.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @return [Hash<String, String>] Map of relative path to SHA-256 hex digest.
      #
      def load_manifest(machine)
        path = File.join(machine_data_dir(machine), 'freedos_sync_manifest.json')
        File.exist?(path) ? JSON.parse(File.read(path)) : {}
      end

      #
      # Saves the SHA-256 sync manifest for `machine`.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @param [Hash<String, String>] manifest Map of relative path to SHA-256 hex digest.
      # @return [void]
      #
      def save_manifest(machine, manifest)
        path = File.join(machine_data_dir(machine), 'freedos_sync_manifest.json')
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, JSON.pretty_generate(manifest))
      end
    end
  end
end
