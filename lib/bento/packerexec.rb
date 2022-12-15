module PackerExec
  def for_packer_run_with(template)
    Tempfile.open("#{template}-metadata.json") do |md_file|
      Tempfile.open("#{template}-metadata-var-file") do |var_file|
        write_box_metadata(template, md_file)
        write_var_file(template, md_file, var_file)
        yield md_file, var_file
      end
    end
  end

  def write_box_metadata(template, io)
    md = BuildMetadata.new(template, build_timestamp, override_version).read
    io.write(JSON.pretty_generate(md))
    io.close
  end

  def write_var_file(template, md_file, io)
    md = BuildMetadata.new(template, build_timestamp, override_version).read

    io.write(JSON.pretty_generate({
      box_basename:     md[:box_basename],
      build_timestamp:  md[:build_timestamp],
      git_revision:     md[:git_revision],
      metadata:         md_file.path,
      version:          md[:version],
    }))
    io.close
  end
end
