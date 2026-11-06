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
      #
      # Initializes internal Vagrant 2 synced folder plugin state.
      #
      # @param [Object] *_args Ignored initialization arguments.
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

        write_directory_to_fat16(ensure_sync_disk(machine), stage_dir)
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
        disk_path = sync_disk_path(machine)
        extract_fat16_to_directory(disk_path, stage_dir) if File.exist?(disk_path)
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
      # Creates and formats a partitioned MBR + FAT16 sync disk image (`msdos_sync_d.raw`)
      # if it does not yet exist or lacks a valid MBR signature.
      #
      # @param [Object] machine The Vagrant machine instance.
      # @param [Integer] size_mb Size of the disk image in megabytes (default `16`).
      # @return [String] Path to the created or existing sync disk image.
      #
      def ensure_sync_disk(machine, size_mb: 16)
        path = sync_disk_path(machine)
        FileUtils.mkdir_p(File.dirname(path))
        format_fat16_image(path, size_mb: size_mb) unless valid_mbr_fat16_image?(path)
        path
      end

      #
      # Checks whether `path` exists and starts with a valid MBR signature (`0x55AA`)
      # and a formatted FAT16 partition at LBA 63.
      #
      # @param [String] path Path to the raw disk image.
      # @return [Boolean] True if the disk image has a valid MBR and FAT16 boot sector.
      #
      def valid_mbr_fat16_image?(path)
        return false unless File.exist?(path) && File.size(path) >= (64 * 512)

        File.open(path, 'rb') do |f|
          mbr = f.read(512)
          f.seek(63 * 512)
          vbr = f.read(512)
          mbr && mbr.bytesize == 512 && mbr.byteslice(510, 2) == "\x55\xAA".b &&
            vbr && vbr.bytesize == 512 && vbr.byteslice(510, 2) == "\x55\xAA".b
        end
      end

      #
      # Initializes `path` as a partitioned MBR hard disk image with a single active
      # primary FAT16 partition (`type 0x04`) starting at LBA 63.
      #
      # @param [String] path Destination file path for the raw disk image.
      # @param [Integer] size_mb Total disk image size in MiB (default `16`).
      # @return [String] Path to the formatted image.
      #
      def format_fat16_image(path, size_mb: 16)
        total_sectors = (size_mb * 1024 * 1024) / 512
        part_lba = 63
        part_sectors = total_sectors - part_lba
        FileUtils.mkdir_p(File.dirname(path))

        File.open(path, 'wb') do |f|
          f.truncate(total_sectors * 512)
          # Build MBR with 1 active primary FAT16 (<32MB, 0x04) partition at LBA 63
          mbr = ("\x00" * 512).b
          entry = [
            0x80,       # status: active
            1, 1, 0,    # start CHS (head 1, sector 1, cyl 0)
            0x04,       # type: FAT16 <32MB
            15, 63, 31, # end CHS
            part_lba,   # LBA start
            part_sectors
          ].pack('CCCCCCC CVV')
          mbr[446, 16] = entry
          mbr[510, 2] = "\x55\xAA".b
          f.seek(0)
          f.write(mbr)

          # Build FAT16 Volume Boot Record at LBA 63
          vbr = ("\x00" * 512).b
          vbr[0, 3]   = "\xEB\x3C\x90".b
          vbr[3, 8]   = 'MSDOS4.0'.b
          vbr[11, 25] = [
            512,          # bytes per sector
            4,            # sectors per cluster (2KB clusters)
            1,            # reserved sectors
            2,            # number of FATs
            512,          # max root directory entries (32 sectors)
            part_sectors, # total 16-bit sectors
            0xF8,         # media descriptor (fixed disk)
            32,           # sectors per FAT
            63,           # sectors per track
            16,           # heads
            part_lba,     # hidden sectors
            0             # total 32-bit sectors
          ].pack('vCvCvvCvvvVV')
          vbr[36, 26] = [0x80, 0, 0x29, 0x1988_0400, 'BENTO_SYNC ', 'FAT16   '].pack('CCCVA11A8')
          vbr[510, 2] = "\x55\xAA".b
          f.seek(part_lba * 512)
          f.write(vbr)

          # Initialize FAT #1 and FAT #2 media descriptor entries (F8 FF FF FF)
          fat_head = "\xF8\xFF\xFF\xFF".b + ("\x00" * ((32 * 512) - 4)).b
          f.seek((part_lba + 1) * 512)
          f.write(fat_head)
          f.seek((part_lba + 1 + 32) * 512)
          f.write(fat_head)

          # Zero out 32-sector root directory
          f.seek((part_lba + 1 + 64) * 512)
          f.write(("\x00" * (32 * 512)).b)
        end
        path
      end

      #
      # Writes all files from `source_dir` into the FAT16 partition inside `disk_path`.
      #
      # @param [String] disk_path Path to the MBR+FAT16 raw disk image.
      # @param [String] source_dir Directory containing files to write into the FAT16 root/subdirectories.
      # @return [Integer] Number of files written into the FAT16 partition.
      #
      def write_directory_to_fat16(disk_path, source_dir)
        return 0 unless File.directory?(source_dir)

        format_fat16_image(disk_path)
        files = collect_host_files(source_dir, [])
        part_lba = 63
        fat1_offset = (part_lba + 1) * 512
        fat2_offset = (part_lba + 1 + 32) * 512
        root_offset = (part_lba + 1 + 64) * 512
        data_offset = (part_lba + 1 + 64 + 32) * 512
        cluster_size = 4 * 512

        File.open(disk_path, 'r+b') do |f|
          fat = Array.new(32 * 256, 0)
          fat[0] = 0xFFF8
          fat[1] = 0xFFFF
          next_cluster = 2
          root_entries = []

          files.first(512).each do |rel_path|
            full_path = File.join(source_dir, rel_path)
            data = File.binread(full_path)
            flat_name = normalize_8_3_segment(rel_path.tr('/', '_'))
            stem, ext = flat_name.split('.', 2)
            name8 = (stem || '').ljust(8, ' ')[0, 8]
            ext3  = (ext || '').ljust(3, ' ')[0, 3]

            if data.empty?
              first_cluster = 0
            else
              first_cluster = next_cluster
              chunks = data.bytes.each_slice(cluster_size).map { |s| s.pack('C*') }
              chunks.each_with_index do |chunk, idx|
                cur = next_cluster
                next_cluster += 1
                fat[cur] = (idx == chunks.length - 1) ? 0xFFFF : next_cluster
                f.seek(data_offset + ((cur - 2) * cluster_size))
                f.write(chunk.ljust(cluster_size, "\x00"))
              end
            end

            entry = [
              name8, ext3, 0x20, "\x00" * 14, first_cluster, data.bytesize
            ].pack('A8A3Ca14vV')
            root_entries << entry
          end

          fat_bytes = fat.pack('v*')
          f.seek(fat1_offset)
          f.write(fat_bytes)
          f.seek(fat2_offset)
          f.write(fat_bytes)

          f.seek(root_offset)
          f.write(root_entries.join.ljust(32 * 512, "\x00"))
        end
        files.length
      end

      #
      # Extracts files from the FAT16 root directory inside `disk_path` into `dest_dir`.
      #
      # @param [String] disk_path Path to the MBR+FAT16 raw disk image.
      # @param [String] dest_dir Destination directory on the host.
      # @return [Array<String>] List of extracted filenames.
      #
      def extract_fat16_to_directory(disk_path, dest_dir)
        return [] unless valid_mbr_fat16_image?(disk_path)

        FileUtils.mkdir_p(dest_dir)
        part_lba = 63
        fat1_offset = (part_lba + 1) * 512
        root_offset = (part_lba + 1 + 64) * 512
        data_offset = (part_lba + 1 + 64 + 32) * 512
        cluster_size = 4 * 512
        extracted = []

        File.open(disk_path, 'rb') do |f|
          f.seek(fat1_offset)
          fat = f.read(32 * 512).unpack('v*')
          f.seek(root_offset)
          root_raw = f.read(32 * 512)

          (0...512).each do |idx|
            entry = root_raw.byteslice(idx * 32, 32)
            first_byte = entry.getbyte(0)
            break if first_byte == 0x00
            next if first_byte == 0xE5

            attr = entry.getbyte(11)
            next if (attr & 0x08) != 0 || (attr & 0x10) != 0

            stem = entry.byteslice(0, 8).strip
            ext  = entry.byteslice(8, 3).strip
            fname = ext.empty? ? stem : "#{stem}.#{ext}"
            next if fname.empty?

            first_cluster = entry.byteslice(26, 2).unpack1('v')
            file_size     = entry.byteslice(28, 4).unpack1('V')

            content = +''.b
            cur = first_cluster
            while cur >= 2 && cur < 0xFFF0 && content.bytesize < file_size
              f.seek(data_offset + ((cur - 2) * cluster_size))
              content << f.read(cluster_size).to_s
              cur = fat[cur] || 0xFFFF
            end
            content = content.byteslice(0, file_size) || ''.b

            out_path = File.join(dest_dir, fname)
            File.binwrite(out_path, content)
            extracted << fname
          end
        end
        extracted
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
