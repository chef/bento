# frozen_string_literal: true

#
# @file synced_folder.rb
# @brief Bidirectional synced folder plugin for Microsoft MS-DOS (`type: :msdos_sync`)
# @description
#   Implements `Vagrant.plugin("2", :synced_folder)` for MS-DOS (1.25, 2.0, 4.0) guests, supporting:
#   1. Host -> Guest synchronization (`sync_to_guest`):
#      - Creates/updates a secondary FAT12/FAT16 disk image (`msdos_sync_d.raw`)
#        and stages files into `msdos_drive_d` or pushes live over the serial/telnet
#        communicator.
#      - Normalizes paths into DOS 8.3 format (`normalize_8_3_path`), supporting both
#        flat root staging (for MS-DOS 1.25) and hierarchical directories (MS-DOS 2.0/4.0).
#      - Optional CRLF conversion for DOS text/source/batch files (`.BAT`, `.ASM`, `.C`, `.H`, `.MAK`).
#   2. Guest -> Host synchronization (`sync_to_host`):
#      - Extracts newly created or modified build/test artifacts (`.COM`, `.EXE`, `.OBJ`,
#        `.SYS`, `.MAP`, `.LST`, `.TXT`, `.LOG`) from MS-DOS `D:` back into the host
#        workspace directory after commands or before VM halt.
#

require 'fileutils'
require 'digest'
require 'json'

module Bento
  module VagrantMsdos
    #
    # @class SyncedFolder
    # @description
    #   Manages bidirectional directory synchronization between a host directory
    #   and an MS-DOS (1.25, 2.0, 4.0) guest drive (default `D:`).
    #
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
      TEXT_EXTENSIONS = %w[.bat .cmd .c .h .cpp .hpp .asm .inc .wat .mak .lnk .cfg .pas .bas .txt .doc].freeze

      #
      # Determines whether the `:msdos_sync` synced folder plugin is usable for `machine`.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @param [Boolean] _raise_error Whether to raise an exception if unusable.
      # @return [Boolean] True when the machine is configured as an MS-DOS guest.
      #
      def usable?(machine, _raise_error = false)
        CommandSsh.msdos_machine?(machine)
      end

      #
      # Prepares the secondary FAT sync disk image before the MS-DOS VM boots.
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
      # Enables synced folders once the MS-DOS VM has booted and performs live sync if needed.
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
      # Normalizes a relative POSIX path into a DOS 8.3 path (or flat 8.3 filename when `flat: true`
      # for MS-DOS 1.25).
      #
      # @param [String] rel_path Relative path on the host.
      # @param [Boolean] flat Whether to flatten directory segments into a single root filename.
      # @return [String] Normalized 8.3 relative path.
      #
      def normalize_8_3_path(rel_path, flat: false)
        segments = rel_path.to_s.split('/').reject(&:empty?)
        return normalize_8_3_segment(segments.join('_')) if flat

        segments.map { |seg| normalize_8_3_segment(seg) }.join('/')
      end

      #
      # Synchronizes files from `host_dir` on the host into the MS-DOS guest sync drive (`D:`).
      # Updates both the staging/FAT disk image and (if `live_push: true`) uploads changed
      # files directly over the communicator.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @param [String] host_dir Host directory path to sync from.
      # @param [Hash] opts Folder synchronization options (`:drive`, `:exclude`, `:crlf_convert`, `:live_push`, `:flat`).
      # @return [Array<String>] List of relative file paths synchronized to the guest.
      #
      def sync_to_guest(machine, host_dir, opts = {})
        return [] unless host_dir && File.directory?(host_dir)

        drive = opts.fetch(:drive, 'D:')
        excludes = Array(opts.fetch(:exclude, ['.git/', '.vagrant/', 'builds/']))
        crlf_convert = opts.fetch(:crlf_convert, false)
        live_push = opts.fetch(:live_push, false)
        flat_mode = opts.fetch(:flat, !subdirectories_supported?(machine))

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

          guest_rel = flat_mode ? normalize_8_3_path(rel_path, flat: true) : rel_path
          staged_file = File.join(stage_dir, guest_rel)
          FileUtils.mkdir_p(File.dirname(staged_file))
          File.binwrite(staged_file, payload)

          if live_push && machine.respond_to?(:communicate)
            dos_rel = guest_rel.tr('/', BS)
            machine.communicate.upload(staged_file, "#{drive}#{BS}#{dos_rel}")
          end

          manifest[rel_path] = digest
          synced_rel_paths << rel_path
        end

        save_manifest(machine, manifest)
        synced_rel_paths
      end

      #
      # Synchronizes newly created or modified files from the MS-DOS guest sync drive (`D:`)
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
      # Returns the path to the secondary FAT12/FAT16 disk image (`msdos_sync_d.raw`) for `machine`.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @return [String] Absolute path to the sync disk image.
      #
      def sync_disk_path(machine)
        File.join(machine_data_dir(machine), 'msdos_sync_d.raw')
      end

      #
      # Returns the host staging directory representing the contents of the MS-DOS `D:` drive.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @return [String] Path to the staging directory.
      #
      def guest_stage_dir(machine)
        File.join(machine_data_dir(machine), 'msdos_drive_d')
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
        path = File.join(machine_data_dir(machine), 'msdos_folders.json')
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
        path = File.join(machine_data_dir(machine), 'msdos_folders.json')
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
      # Checks whether the machine's MS-DOS configuration supports subdirectories.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @return [Boolean] True if subdirectories are supported (v2.0 / v4.0), false on v1.25.
      #
      def subdirectories_supported?(machine)
        if machine.respond_to?(:config) && machine.config.respond_to?(:msdos) &&
           machine.config.msdos.respond_to?(:supports_subdirectories?)
          machine.config.msdos.supports_subdirectories?
        else
          true
        end
      end

      #
      # Normalizes a single filename component into an uppercase DOS 8.3 name.
      #
      # @param [String] segment Filename component.
      # @return [String] Uppercase 8.3-compatible filename component.
      #
      def normalize_8_3_segment(segment)
        ext = File.extname(segment)
        stem = File.basename(segment, ext)
        clean_stem = stem.upcase.gsub(/[^A-Z0-9_-]/, '_')[0, 8]
        clean_ext = ext.sub(/\A\./, '').upcase.gsub(/[^A-Z0-9_-]/, '')[0, 3]
        clean_ext.empty? ? clean_stem : "#{clean_stem}.#{clean_ext}"
      end

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
          File.join(Dir.tmpdir, 'bento_vagrant_msdos_default')
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
        path = File.join(machine_data_dir(machine), 'msdos_sync_manifest.json')
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
        path = File.join(machine_data_dir(machine), 'msdos_sync_manifest.json')
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, JSON.pretty_generate(manifest))
      end
    end
  end
end
