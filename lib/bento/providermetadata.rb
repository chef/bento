require "digest"
require "bento/common"

class ProviderMetadata
  include Common

  def initialize(path, box_basename)
    @base = File.join(path, box_basename)
  end

  def read
    Dir.glob("#{base}.*.box").map do |file|
      {
        name: provider_from_file(file),
        version: version(provider_from_file(file)),
        file: "#{File.basename(file)}",
        checksum_type: "sha256",
        checksum: shasum(file),
        size: "#{size_in_mb(file)} MB",
      }
    end
  end

  private

  attr_reader :base

  def provider_from_file(file)
    provider = file.sub(/^.*\.([^.]+)\.box$/, '\1')
    if provider == "vmware"
      "vmware_desktop"
    else
      provider
    end
  end

  def shasum(file)
    Digest::SHA256.file(file).hexdigest
  end

  def size_in_mb(file)
    size = File.size(file)
    size_mb = size / MEGABYTE
    size_mb.ceil.to_s
  end

  def version(provider)
    case provider
    when /vmware/
      ver_vmware
    when /virtualbox/
      ver_vbox
    when /parallels/
      ver_parallels
    end
  end

  def ver_vmware
    if macos?
      path = File.join('/Applications/VMware\ Fusion.app/Contents/Library')
      fusion_cmd = File.join(path, "vmware-vmx -v")
      cmd = Mixlib::ShellOut.new(fusion_cmd)
      cmd.run_command
      cmd.stderr.split(" ")[5]
    else
      cmd = Mixlib::ShellOut.new("vmware --version")
      cmd.run_command
      cmd.stdout.split(" ")[2]
    end
  end

  def ver_parallels
    raise "Platform is not macOS, exiting..." unless macos?

    cmd = Mixlib::ShellOut.new("prlctl --version")
    cmd.run_command
    cmd.stdout.split(" ")[2]
  end

  def ver_vbox
    cmd = Mixlib::ShellOut.new("VBoxManage --version")
    cmd.run_command
    cmd.stdout.split("r")[0]
  end
end
