# frozen_string_literal: true

#
# @file common.rb
# @brief Common shared utility methods and environment inspection helpers for Bento
# @description
#   Provides cross-cutting helper methods for console banner output, timing,
#   Vagrant Cloud authentication checks, metadata parsing, YAML configuration loading,
#   and proprietary OS classification.
#

require 'benchmark' unless defined?(Benchmark)
require 'fileutils' unless defined?(FileUtils)
require 'json' unless defined?(JSON)
require 'tempfile' unless defined?(Tempfile)
require 'yaml'
require 'mixlib/shellout' unless defined?(Mixlib::ShellOut)

MEGABYTE = 1024.0 * 1024.0

#
# @module Common
# @description Shared helper module mixed into Bento runner, build, and metadata classes.
#
module Common
  #
  # Prints a banner-formatted notification message.
  #
  # @param [String] msg The text message to display.
  # @return [void]
  #
  def banner(msg)
    puts "==> #{msg}"
  end

  #
  # Prints an indented informational message.
  #
  # @param [String] msg The text message to display.
  # @return [void]
  #
  def info(msg)
    puts "    #{msg}"
  end

  #
  # Shells out to execute an external command with live streaming and error checking.
  #
  # @param [String] cmd Shell command string to execute.
  # @return [Mixlib::ShellOut] ShellOut execution instance.
  #
  def shellout(cmd)
    info "Shelling out to run #{cmd}"
    sout = Mixlib::ShellOut.new(cmd)
    sout.live_stream = $stdout
    sout.run_command
    sout.error! # fail hard if the cmd fails
  end

  #
  # Prints a warning message prefixed with '>>>'.
  #
  # @param [String] msg The warning text to display.
  # @return [void]
  #
  def warn(msg)
    puts ">>> #{msg}"
  end

  #
  # Shells out to vagrant CLI to check authentication status with Vagrant Cloud.
  #
  # @return [Boolean] True if currently authenticated, false otherwise.
  #
  def logged_in?
    # rubocop:disable Modernize/ShellOutHelper
    shellout = Mixlib::ShellOut.new('vagrant cloud auth whoami').run_command
    # rubocop:enable Modernize/ShellOutHelper

    if shellout.error?
      error_output = !shellout.stderr.empty? ? shellout.stderr : shellout.stdout
      warn("Failed to shellout to vagrant to check the login status. Error: #{error_output}")
      return false
    end

    return true if shellout.stdout.match?(/Currently logged in/)

    false
  end

  #
  # Formats a duration in seconds into a human-readable minutes and seconds string.
  #
  # @param [Numeric, NilClass] total Total elapsed time in seconds.
  # @return [String] Formatted duration string (e.g., '2m15.50s').
  #
  def duration(total)
    total = 0 if total.nil?
    minutes = (total / 60).to_i
    seconds = (total - (minutes * 60))
    format('%dm%.2fs', minutes, seconds)
  end

  #
  # Reads and parses a JSON box metadata file.
  #
  # @param [String] metadata_file File path to the JSON metadata file.
  # @return [Hash] Parsed JSON metadata hash.
  #
  def box_metadata(metadata_file)
    JSON.parse(File.read(metadata_file))
  end

  #
  # Globs for metadata files in build or testing directories based on flags and architecture.
  #
  # @param [Boolean] arch_support Whether to append host architecture filter to glob.
  # @param [Boolean] upload Whether to look in testing_passed rather than build_complete.
  # @return [Array<String>] Matching metadata file paths.
  #
  def metadata_files(arch_support = false, upload = false)
    arch = if RbConfig::CONFIG['host_cpu'] == 'arm64'
             'aarch64'
           else
             RbConfig::CONFIG['host_cpu']
           end
    glob = if upload
             "builds/testing_passed/**/*#{"-#{arch}" if arch_support}._metadata.json"
           else
             "builds/build_complete/*#{"-#{arch}" if arch_support}._metadata.json"
           end
    @metadata_files ||= Dir.glob(glob)
  end

  #
  # Loads and parses the root builds.yml configuration file.
  #
  # @return [Hash] Configuration hash from builds.yml.
  #
  def builds_yml
    YAML.load_file('builds.yml')
  end

  #
  # Determines whether an operating system distribution requires private distribution
  # due to commercial or proprietary licensing restrictions.
  #
  # @param [String] boxname Box name string to evaluate.
  # @return [Boolean] True if proprietary/commercial, false if open/public.
  #
  def private_box?(boxname)
    proprietary_os_list = %w(macos windows sles solaris rhel)
    proprietary_os_list.any? { |p| boxname.include?(p) }
  end

  #
  # Checks whether the current host platform is macOS (Darwin).
  #
  # @return [Boolean] True if running on macOS.
  #
  def macos?
    !(RUBY_PLATFORM =~ /darwin/).nil?
  end

  #
  # Checks whether the current host platform is a Unix-like system.
  #
  # @return [Boolean] True if Unix-like, false on Windows.
  #
  def unix?
    !windows?
  end

  #
  # Checks whether the current host platform is Windows.
  #
  # @return [Boolean] True if running on Windows.
  #
  def windows?
    !(RUBY_PLATFORM =~ /mswin|mingw|windows/).nil?
  end
end
