
require 'mixlib/shellout'
require 'etc'
module Bento
  class VagrantUtmMacosSnapshot
    def self.utm_documents_dir
      username = ENV['USER'] || Etc.getlogin
      "/Users/#{username}/Library/Containers/com.utmapp.UTM/Data/Documents"
    end
    def self.apple_backend?(vm_name, docs_dir = utm_documents_dir)
      bundle_path = File.join(docs_dir, "#{vm_name}.utm")
      return false unless Dir.exist?(bundle_path)

      data_img = File.join(bundle_path, 'Data', 'Data.img')
      root_data_img = File.join(bundle_path, 'Data.img')
      return true if File.exist?(data_img) || File.exist?(root_data_img)

      config_plist = File.join(bundle_path, 'config.plist')
      if File.exist?(config_plist)
        content = File.read(config_plist)
        return true if content.include?('<string>Apple</string>') || content.include?('Backend</key>') && content.include?('Apple')
      end

      false
    end
    def self.snapshot_clone_name(vm_name, snapshot_name)
      "#{vm_name}-snapshot-#{snapshot_name}"
    end
    def self.execute_command(cmd)
      sout = Mixlib::ShellOut.new(cmd)
      sout.run_command
      if sout.error?
        raise "Command '#{cmd}' failed with status #{sout.exitstatus}: #{sout.stderr.strip}"
      end

      sout.stdout.strip
    end
    def self.resolve_machine_name(driver, machine_id)
      list = driver.list
      item = list.find(uuid: machine_id)
      raise "Could not resolve machine name for identifier: #{machine_id}" unless item

      item.name
    end
    def self.create_snapshot(driver, machine_id, snapshot_name)
      vm_name = resolve_machine_name(driver, machine_id)
      if apple_backend?(vm_name)
        clone_name = snapshot_clone_name(vm_name, snapshot_name)
        execute_command("utmctl clone \"#{vm_name}\" --name \"#{clone_name}\"")
      else
        driver.orig_create_snapshot(machine_id, snapshot_name)
      end
    end
    def self.delete_snapshot(driver, machine_id, snapshot_name)
      vm_name = resolve_machine_name(driver, machine_id)
      if apple_backend?(vm_name)
        clone_name = snapshot_clone_name(vm_name, snapshot_name)
        execute_command("utmctl delete \"#{clone_name}\"")
      else
        driver.orig_delete_snapshot(machine_id, snapshot_name)
      end
    end
    def self.list_snapshots(driver, machine_id)
      vm_name = resolve_machine_name(driver, machine_id)
      if apple_backend?(vm_name)
        output = execute_command('utmctl list')
        prefix = "#{vm_name}-snapshot-"
        snapshots = []
        output.each_line do |line|
          line = line.strip
          next if line.empty?

          # utmctl list output format: <UUID> <NAME> [status]
          parts = line.split(/\s+/)
          next if parts.length < 2

          name_candidate = parts[1]
          if name_candidate.start_with?(prefix)
            snapshots << name_candidate.sub(prefix, '')
          end
        end
        snapshots
      else
        driver.orig_list_snapshots(machine_id)
      end
    end
    def self.restore_snapshot(driver, machine_id, snapshot_name)
      vm_name = resolve_machine_name(driver, machine_id)
      if apple_backend?(vm_name)
        available = list_snapshots(driver, machine_id)
        unless available.include?(snapshot_name)
          raise "Snapshot '#{snapshot_name}' does not exist for virtual machine '#{vm_name}'."
        end

        clone_name = snapshot_clone_name(vm_name, snapshot_name)

        # Stop active machine if running
        begin
          execute_command("utmctl stop \"#{vm_name}\"")
        rescue RuntimeError
          # If already stopped, ignore error
        end

        # Remove active VM and recreate from snapshot clone
        execute_command("utmctl delete \"#{vm_name}\"")
        execute_command("utmctl clone \"#{clone_name}\" --name \"#{vm_name}\"")
      else
        driver.orig_restore_snapshot(machine_id, snapshot_name)
      end
    end
    def self.patch_driver!(driver_class)
      return if driver_class.instance_variable_get(:@macos_snapshot_patched)

      driver_class.class_eval do
        alias_method :orig_create_snapshot, :create_snapshot if method_defined?(:create_snapshot)
        alias_method :orig_delete_snapshot, :delete_snapshot if method_defined?(:delete_snapshot)
        alias_method :orig_list_snapshots, :list_snapshots if method_defined?(:list_snapshots)
        alias_method :orig_restore_snapshot, :restore_snapshot if method_defined?(:restore_snapshot)

        define_method(:create_snapshot) do |machine_id, snapshot_name|
          Bento::VagrantUtmMacosSnapshot.create_snapshot(self, machine_id, snapshot_name)
        end

        define_method(:delete_snapshot) do |machine_id, snapshot_name|
          Bento::VagrantUtmMacosSnapshot.delete_snapshot(self, machine_id, snapshot_name)
        end

        define_method(:list_snapshots) do |machine_id|
          Bento::VagrantUtmMacosSnapshot.list_snapshots(self, machine_id)
        end

        define_method(:restore_snapshot) do |machine_id, snapshot_name|
          Bento::VagrantUtmMacosSnapshot.restore_snapshot(self, machine_id, snapshot_name)
        end
      end

      driver_class.instance_variable_set(:@macos_snapshot_patched, true)
    end
    def self.install!
      if defined?(VagrantPlugins::Utm::Driver::Version_4_5)
        patch_driver!(VagrantPlugins::Utm::Driver::Version_4_5)
      end
      if defined?(VagrantPlugins::Utm::Driver::Meta)
        patch_driver!(VagrantPlugins::Utm::Driver::Meta)
      end
      true
    end
  end
end
