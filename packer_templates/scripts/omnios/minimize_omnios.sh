#!/bin/sh
#
# @file minimize_omnios.sh
# @brief Disk space minimization and cleanup script for OmniOS Vagrant base box
# @description
#   Cleans IPS package caches, purges temporary and transient state files, removes
#   system and SMF logs, and zeroes unoccupied pool blocks so compression algorithms
#   can minimize the final Vagrant box artifact size.
#
set -ux

#
# @function clean_package_cache
# @description
#   Purges cached package archives and index metadata from IPS local storage.
# @noargs
# @return [Integer] Returns 0 on completion.
#
clean_package_cache() {
  echo "Purging IPS package caches..."
  pkg clean -a 2>/dev/null || true
  rm -rf /var/pkg/download/* 2>/dev/null || true
}

#
# @function clean_temporary_files
# @description
#   Removes temporary files from /tmp and /var/tmp directories.
# @noargs
# @return [Integer] Returns 0 on completion.
#
clean_temporary_files() {
  echo "Clearing temporary files..."
  rm -rf /tmp/* /var/tmp/* 2>/dev/null || true
}

#
# @function clean_logs
# @description
#   Truncates or purges system log files and SMF service execution logs.
# @noargs
# @return [Integer] Returns 0 on completion.
#
clean_logs() {
  echo "Clearing system and SMF service logs..."
  rm -rf /var/svc/log/*.log 2>/dev/null || true
  for _log in /var/log/syslog /var/log/messages /var/adm/messages /var/adm/wtmpx /var/adm/utmpx; do
    if [ -f "$_log" ]; then
      cp /dev/null "$_log" 2>/dev/null || true
    fi
  done
}

#
# @function zero_disk_free_space
# @description
#   Fills unallocated storage space in the root ZFS dataset with zeroes and deletes
#   the sentinel file to optimize sparse disk image compression.
# @param [String] target_dir Directory path where zero file should be generated.
# @return [Integer] Returns 0 on completion.
#
zero_disk_free_space() {
  _target_dir="$1"
  _zero_file="${_target_dir}/zero_fill"

  echo "Zeroing unallocated disk space in ${_target_dir}..."
  sync
  # dd will exit with an error code once the filesystem fills up, which is expected
  dd if=/dev/zero of="$_zero_file" bs=1048576 2>/dev/null || true
  sync
  rm -f "$_zero_file"
  sync

  # Issue zpool trim on rpool if supported by illumos release
  if command -v zpool >/dev/null 2>&1; then
    zpool trim rpool 2>/dev/null || true
  fi
}

#
# @function main
# @description
#   Main coordination function performing complete disk minimization sequence.
# @noargs
# @return [Integer] Returns 0 on completion.
#
main() {
  clean_package_cache
  clean_temporary_files
  clean_logs

  _zero_dir="/export/home"
  if [ ! -d "$_zero_dir" ]; then
    _zero_dir="/"
  fi
  zero_disk_free_space "$_zero_dir"
}

main
