require "bento/common"

class UploadRunner
  include Common

  attr_reader :md_json

  def initialize(opts)
    @md_json = opts.md_json
  end

  def start
    banner("Starting uploads...")
    time = Benchmark.measure do
      files = md_json ? [md_json] : metadata_files
      files.each do |md_file|
        upload(md_file)
      end
    end
    banner("Uploads finished in #{duration(time.real)}.")
  end

  def upload(md_file)
    puts "Attempting to upload #{md_file}"
    md = box_metadata(md_file)
    box_desc = "a bento box for #{md['name']}"
    box = vc_account.ensure_box(md["name"], {short_description: box_desc, is_private: private_box?(md["name"])})
    box_ver = box.ensure_version(md["version"], File.read(md_file))

    if builds_yml["slugs"].value?(box.name)
      slug_desc = "a bento box for #{builds_yml['slugs'].key(box.name)}"
      slug = vc_account.ensure_box(builds_yml["slugs"].key(box.name), {short_description: slug_desc, is_private: false})
      slug_ver = slug.ensure_version(md["version"], File.read(md_file))
    end

    md["providers"].each do |k, v|
      provider = box_ver.ensure_provider(k, nil)
      banner("Uploading #{box.name}/#{box_ver.version}/#{provider.name}...")
      provider.upload_file("builds/#{v['file']}")
      banner(provider.download_url.to_s)
      next unless builds_yml["slugs"].value?(box.name)

      slug_provider = slug_ver.ensure_provider(k, nil)
      banner("Uploading #{slug.name}/#{slug_ver.version}/#{slug_provider.name}...")
      slug_provider.upload_file("builds/#{v['file']}")
      banner(slug_provider.download_url.to_s)
    end
  end
end
