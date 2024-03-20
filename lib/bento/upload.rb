require 'bento/common'

class UploadRunner
  include Common

  attr_reader :md_json

  def initialize(opts)
    @md_json = opts.md_json
  end

  def error_unless_logged_in
    warn("You cannot upload files to vagrant cloud unless the vagrant CLI is logged in. Run 'vagrant cloud auth login' first.") unless logged_in?
  end

  def start
    error_unless_logged_in

    banner('Starting uploads...')
    time = Benchmark.measure do
      files = md_json ? [md_json] : metadata_files
      files.each do |md_file|
        upload_box(md_file)
      end
    end
    banner("Uploads finished in #{duration(time.real)}.")
  end

  #
  # Upload all the boxes defined in the passed metadata file
  #
  # @param [String] md_file The path to the metadata file
  #
  #
  def upload_box(md_file)
    md_data = box_metadata(md_file)
    arch = case md_data['arch']
           when 'x86_64', 'amd64'
             'amd64'
           when 'aarch64', 'arm64'
             'arm64'
           else
             raise "Unknown arch #{md_data.inspect}"
           end
    md_data['providers'].each_pair do |prov, prov_data|
      if File.exist?(File.join('builds', prov_data['file']))
        puts ''
        banner("Uploading #{builds_yml['vagrant_cloud_account']}/#{md_data['box_basename']} version:#{md_data['version']} provider:#{prov} arch:#{arch}...")
        upload_cmd = "vagrant cloud publish --architecture #{arch} #{default_arch(arch)} --no-direct-upload #{builds_yml['vagrant_cloud_account']}/#{md_data['box_basename']} #{md_data['version']} #{prov} builds/#{prov_data['file']} --description '#{box_desc(md_data['box_basename'])}' --short-description '#{box_desc(md_data['box_basename'])}' --version-description '#{ver_desc(md_data)}' --force --release #{public_private_box(md_data['box_basename'])}"
        shellout(upload_cmd)

        slug_name = lookup_slug(md_data['name'])
        if slug_name
          puts ''
          banner("Uploading slug #{builds_yml['vagrant_cloud_account']}/#{slug_name} from #{md_data['box_basename']} version:#{md_data['version']} provider:#{prov} arch:#{arch}...")
          upload_cmd = "vagrant cloud publish --architecture #{arch} --no-direct-upload #{builds_yml['vagrant_cloud_account']}/#{slug_name} #{md_data['version']} #{prov} builds/#{prov_data['file']} --description '#{slug_desc(slug_name)}' --short-description '#{slug_desc(slug_name)}' --version-description '#{ver_desc(md_data)}' --force --release  #{public_private_box(md_data['box_basename'])}"
          shellout(upload_cmd)
        end

        # move the box file to the completed directory
        FileUtils.mv(File.join('builds', prov_data['file']), File.join('builds', 'uploaded', prov_data['file']))
      else # box in metadata isn't on disk
        warn "The #{prov} box defined in the metadata file #{md_file} does not exist at builds/#{prov_data['file']}. Skipping!"
      end
    end

    # move the metadata file to the completed directory
    FileUtils.mv(md_file, File.join('builds', 'uploaded', File.basename(md_file)))
  end

  #
  # Given a box name return a slug name or nil
  #
  # @return [String, NilClass] The slug name or nil
  #
  def lookup_slug(name)
    builds_yml['slugs'].each_pair do |slug, match_string|
      return slug if name.start_with?(match_string)
    end

    nil
  end

  def public_private_box(name)
    builds_yml['public'].each do |public|
      return '--no-private' if name.start_with?(public)
    end
    '--private'
  end

  def default_arch(architecture)
    builds_yml['default_architectures'].each do |arch|
      return '--default-architecture' if architecture.eql?(arch)
    end
    '--no-default-architecture'
  end

  def box_desc(name)
    "Vanilla #{name.tr('-', ' ').capitalize} Vagrant box created with Bento by Progress Chef"
  end

  def slug_desc(name)
    "Vanilla #{name.tr('-', ' ').capitalize} Vagrant box created with Bento by Progress Chef. This box will be updated with the latest releases of #{name.tr('-', ' ').capitalize} as they become available"
  end

  def ver_desc(md_data)
    tool_versions = []
    md_data['providers'].each_key do |hv|
      tool_versions << if hv == 'vmware_desktop'
                         if macos?
                           "vmware-fusion: #{md_data['providers'][hv]['version']}"
                         else
                           "vmware-workstation: #{md_data['providers'][hv]['version']}"
                         end
                       else
                         "#{hv}: #{md_data['providers'][hv]['version']}"
                       end
    end
    tool_versions.sort!
    tool_versions << "packer: #{md_data['packer']}"

    "#{md_data['box_basename'].capitalize.tr('-', ' ')} Vagrant box version #{md_data['version']} created with Bento by Progress Chef. Built with: #{tool_versions.join(', ')}"
  end
end
