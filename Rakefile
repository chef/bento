require 'cgi'
require 'json'
require 'net/http'
require 'kitchen'
require 'aws-sdk'
require 'mixlib/shellout'

# TODO:  private boxes may need to specify a mirror

# Enables `bundle exec rake do_all[ubuntu-12.04-amd64,centos-7.1-x86_64]
# http://blog.stevenocchipinti.com/2013/10/18/rake-task-with-an-arbitrary-number-of-arguments/
task :do_all do |task, args|
  args.extras.each do |a|
    # build stage
    Rake::Task['build_box'].invoke(a)
    Rake::Task['build_box'].reenable
  end

  # verification stage
  Rake::Task['test_all'].invoke
  Rake::Task['test_all'].reenable

  # publish stage
  Rake::Task['upload_all'].invoke
  Rake::Task['upload_all'].reenable

  # release stage
  Rake::Task['release_all'].invoke
  Rake::Task['release_all'].reenable
end

desc 'Build a bento template'
task :build_box, :template do |t, args|
  sh "#{build_command(args[:template])}"
end

desc 'Test all boxes with Test Kitchen'
task :test_all do
  metadata_files.each do |metadata_file|
    puts "Processing #{metadata_file} for test."
    Rake::Task['test_box'].invoke(metadata_file)
    Rake::Task['test_box'].reenable
  end
end

desc 'Test a box with Test Kitchen'
task :test_box, :metadata_file do |f, args|
  metadata = box_metadata(args[:metadata_file])
  test_box(metadata['name'], metadata['providers'])
end

desc 'Upload all boxes to Atlas for all providers'
task :upload_all do
  metadata_files.each do |metadata_file|
    puts "Processing #{metadata_file} for upload."
    Rake::Task['upload_box'].invoke(metadata_file)
    Rake::Task['upload_box'].reenable
  end
end

desc 'Upload box files for a single platform to Atlas for all providers'
task :upload_box, :metadata_file do |f, args|
  metadata = box_metadata(args[:metadata_file])
  create_box(metadata['name'])
  create_box_version(metadata['name'], metadata['version'])
  create_providers(metadata['name'], metadata['version'], metadata['providers'].keys)
  upload_to_atlas(metadata['name'], metadata['version'], metadata['providers'])
end

desc 'Upload all boxes to S3 for all providers'
task :upload_all_s3 do
  metadata_files.each do |metadata_file|
    puts "Processing #{metadata_file} for upload."
    Rake::Task['upload_box_s3'].invoke(metadata_file)
    Rake::Task['upload_box_s3'].reenable
  end
end

desc 'Upload box files to S3 for all providers'
task :upload_box_s3, :metadata_file do |f, args|
  metadata = box_metadata(args[:metadata_file])
  upload_to_s3(metadata['name'], metadata['version'], metadata['providers'])
end

desc 'Release all boxes for a given version'
task :release_all do
  metadata_files.each do |metadata_file|
    puts "Processing #{metadata_file} for release."
    metadata = box_metadata(metadata_file)
    release_version(metadata['name'], metadata['version'])
  end
end

desc 'Revoke all boxes for a version'
task :revoke_all, :version do |v, args|
  revoke_version(args[:version])
end

desc 'Delete all boxes for a version'
task :delete_all, :version do |v, args|
  delete_version(args[:version])
end

desc 'Clean the build directory'
task :clean do
  puts 'Removing builds/*.{box,json}'
  `rm -rf builds/*.{box,json}`
  puts 'Removing packer-* directories'
  `rm -rf packer-*`
  puts 'Removing .kitchen.*.yml'
  `rm -f .kitchen.*.yml`
end

def atlas_api
  @atlas_api ||= 'https://atlas.hashicorp.com/api/v1'
end

def atlas_org
  @atlas_org ||= ENV['ATLAS_ORG']
end

def atlas_token
  @atlas_token ||= ENV['ATLAS_TOKEN']
end

def class_for_request(verb)
  Net::HTTP.const_get(verb.to_s.capitalize)
end
def build_uri(verb, path, params = {})
  if %w(delete, get).include?(verb)
    path = [path, to_query_string(params)].compact.join('?')
  end

  # Parse the URI
  uri = URI.parse(path)

  # Don't merge absolute URLs
  uri = URI.parse(File.join(endpoint, path)) unless uri.absolute?

  # Return the URI object
  uri
end

def to_query_string(hash)
  hash.map do |key, value|
    "#{CGI.escape(key)}=#{CGI.escape(value)}"
  end.join('&')[/.+/]
end

def request(verb, url, data = {}, headers = {})
  uri = build_uri(verb, url, data)

  # Build the request.
  request = class_for_request(verb).new(uri.request_uri)
  if %w(patch post put delete).include?(verb)
    if data.respond_to?(:read)
      request.content_length = data.size
      request.body_stream = data
    elsif data.is_a?(Hash)
      request.form_data = data
    else
      request.body = data
    end
  end

  # Add headers
  headers.each do |key, value|
    request.add_field(key, value)
  end

  connection = Net::HTTP.new(uri.host, uri.port)

  if uri.scheme == 'https'
    require 'net/https' unless defined?(Net::HTTPS)

    # Turn on SSL
    connection.use_ssl = true
    connection.verify_mode = OpenSSL::SSL::VERIFY_PEER
  end

  connection.start do |http|
    response = http.request(request)

    case response
      when Net::HTTPRedirection
        redirect = URI.parse(response['location'])
        request(verb, redirect, data, headers)
      else
        response
      end
  end
end

def box_metadata(metadata_file)
  metadata = Hash.new
  file = File.read(metadata_file)
  json = JSON.parse(file)

  # metadata needed for upload:  boxname, version, provider, box filename
  metadata['name'] = json['name']
  metadata['version'] = json['version']
  metadata['box_basename'] = json['box_basename']
  metadata['providers'] = Hash.new
  json['providers'].each do |provider|
    metadata['providers'][provider['name']] = provider.reject { |k, _| k == 'name' }
  end
  metadata
end

def build_command(template)
  cmd = %W[./bin/bento build #{template}]
  cmd.insert(2, "--only #{ENV['BENTO_PROVIDERS']}") if ENV['BENTO_PROVIDERS']
  cmd.insert(2, "--mirror #{ENV['PACKER_MIRROR']}") if private?(template)
  cmd.insert(2, "--version #{ENV['BENTO_VERSION']}") if ENV['BENTO_VERSION']
  cmd.join(" ")
end

def metadata_files
  @metadata_files ||= compute_metadata_files
end

def compute_metadata_files
  `ls builds/*.json`.split("\n")
end

def destroy_all_bento
  cmd = Mixlib::ShellOut.new("vagrant box list | grep 'bento-'")
  cmd.run_command
  boxes = cmd.stdout.split("\n")

  boxes.each do | box |
     b = box.split(" ")
     rm_cmd = Mixlib::ShellOut.new("vagrant box remove --force #{b[0]} --provider #{b[1].to_s.gsub(/(,|\()/, '')}")
     puts "Removing #{b[0]} for provider #{b[1].to_s.gsub(/(,|\()/, '')}"
     rm_cmd.run_command
  end
end

def test_box(boxname, providers)
  providers.each do |provider, provider_data|

    destroy_all_bento

    provider = 'vmware_fusion' if provider == 'vmware_desktop'

    share_disabled = /omnios.*|freebsd.*/ === boxname ? true : false

    puts "Testing provider #{provider} for #{boxname}"
    kitchen_cfg = {"provisioner"=>{"name"=>"chef_zero", "data_path"=>"test/fixtures"},
     "platforms"=>
      [{"name"=>"#{boxname}-#{provider}",
        "driver"=>
         {"name"=>"vagrant",
          "synced_folders"=>[[".", "/vagrant", "disabled: #{share_disabled}"]],
          "provider"=>provider,
          "box"=>"bento-#{boxname}",
          "box_url"=>"file://#{ENV['PWD']}/builds/#{provider_data['file']}"}}],
     "suites"=>[{"name"=>"default", "run_list"=>nil, "attributes"=>{}}]}

    File.open(".kitchen.#{provider}.yml", "w") {|f| f.write(kitchen_cfg.to_yaml) }

    Kitchen.logger = Kitchen.default_file_logger
    @loader = Kitchen::Loader::YAML.new(project_config: "./.kitchen.#{provider}.yml")
    config = Kitchen::Config.new(loader: @loader)
    config.instances.each do |instance|
      instance.test(:always)
    end
  end
end

def create_box(boxname)
  req = request('get', "#{atlas_api}/box/#{atlas_org}/#{boxname}", { 'box[username]' => atlas_org, 'access_token' => atlas_token } )
  if req.code.eql?('404')
    if private?(boxname)
      puts "Creating the private box #{boxname} in atlas."
      req = request('post', "#{atlas_api}/boxes", { 'box[name]' => boxname, 'box[username]' => atlas_org, 'access_token' => atlas_token, 'is_private' => true }, { 'Content-Type' => 'application/json' } )
    else
      puts "Creating the public box #{boxname} in atlas."
      req = request('post', "#{atlas_api}/boxes", { 'box[name]' => boxname, 'box[username]' => atlas_org, 'access_token' => atlas_token, 'is_private' => false }, { 'Content-Type' => 'application/json' } )
    end
  else
    puts "The box #{boxname} exists in atlas, continuing."
  end
end

def create_box_version(boxname, version)
  req = request('post', "#{atlas_api}/box/#{atlas_org}/#{boxname}/versions", { 'version[version]' => version, 'access_token' => atlas_token },{ 'Content-Type' => 'application/json' } )

  puts "Created box version #{boxname} #{version}." if req.code == '200'
  puts "Box version #{boxname} #{version} already exists, continuing." if req.code == '422'
end

def create_providers(boxname, version, provider_names)
  provider_names.each do |provider|
    puts "Creating provider #{provider} for #{boxname} #{version}"
    req = request('post', "#{atlas_api}/box/#{atlas_org}/#{boxname}/version/#{version}/providers", { 'provider[name]' => provider, 'access_token' => atlas_token }, { 'Content-Type' => 'application/json' }  )
    puts "Created #{provider} for #{boxname} #{version}" if req.code == '200'
    puts "Provider #{provider} for #{boxname} #{version} already exists, continuing." if req.code == '422'
  end
end

def upload_to_s3(boxname, version, providers)
  providers.each do |provider, provider_data|
    boxfile = provider_data['file']
    provider = 'vmware' if provider == 'vmware_desktop'
    box_path = "vagrant/#{provider}/opscode_#{boxname}_chef-provisionerless.box"
    credentials = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])

    s3 = Aws::S3::Resource.new(credentials: credentials, endpoint: 'https://s3.amazonaws.com')
    puts "Uploading box: #{boxname} provider: #{provider}"
    s3_object = s3.bucket('opscode-vm-bento').object(box_path)
    s3_object.upload_file("builds/#{boxfile}", acl:'public-read')
    puts "Uploaded to #{s3_object.public_url}"
  end
end

def upload_to_atlas(boxname, version, providers)
  # Extract the upload path
  providers.each do |provider, provider_data|
    boxfile = provider_data['file']
    # Get the upload path.
    req = request('get', "#{atlas_api}/box/#{atlas_org}/#{boxname}/version/#{version}/provider/#{provider}/upload?access_token=#{atlas_token}")
    upload_path = JSON.parse(req.body)['upload_path']
    token = JSON.parse(req.body)['token']

    # Upload the box.
    puts "Uploading the box #{boxfile} to atlas box: #{boxname}, version: #{version}, provider: #{provider}, upload path: #{upload_path}"
    upload_request = request('put', upload_path, File.open("builds/#{boxfile}"))

    # Verify the download token
    req = request('get', "#{atlas_api}/box/#{atlas_org}/#{boxname}/version/#{version}/provider/#{provider}?access_token=#{atlas_token}")
    hosted_token = JSON.parse(req.body)['hosted_token']

    if token == hosted_token
      puts "Successful upload of box #{boxfile} to atlas box: #{boxname}, version: #{version}, provider: #{provider}"
    else
      puts "Failed upload due to non-matching tokens of box #{boxfile} to atlas box: #{boxname}, version: #{version}, provider: #{provider}"
      # need to fail the rake task
    end
 end
end

def release_version(boxname, version)
  puts "Releasing version #{version} of box #{boxname}"
  req = request('put', "#{atlas_api}/box/#{atlas_org}/#{boxname}/version/#{version}/release", { 'access_token' => atlas_token }, { 'Content-Type' => 'application/json' })
  puts "Version #{version} of box #{boxname} has been successfully released" if req.code == '200'
end

def revoke_version(version)
  org = request('get', "#{atlas_api}/user/#{atlas_org}?access_token=#{atlas_token}")
  boxes = JSON.parse(org.body)['boxes']

  boxes.each do |b|
    b['versions'].each do |v|
      if v['version'] == ENV['BENTO_VERSION']
        puts "Revoking version #{v['version']} of box #{b['name']}"
        req = request('put', v['revoke_url'], { 'access_token' => atlas_token }, { 'Content-Type' => 'application/json' })
        if req.code == '200'
          puts "Version #{v['version']} of box #{b['name']} has been successfully revoked"
        else
          puts "Something went wrong #{req.code}"
        end
      end
    end
  end
end

def delete_version(version)
  org = request('get', "#{atlas_api}/user/#{atlas_org}?access_token=#{atlas_token}")
  boxes = JSON.parse(org.body)['boxes']

  boxes.each do |b|
    b['versions'].each do |v|
      if v['version'] == ENV['BENTO_VERSION']
        puts "Deleting version #{v['version']} of box #{b['name']}"
        puts "#{atlas_api}/box/#{atlas_org}/#{b['name']}/version/#{v['version']}"
        req = request('delete', "#{atlas_api}/box/#{atlas_org}/#{b['name']}/version/#{v['version']}", { 'access_token' => atlas_token }, { 'Content-Type' => 'application/json' })
        if req.code == '200'
          puts "Version #{v['version']} of box #{b['name']} has been successfully deleted"
        else
          puts "Something went wrong #{req.code} #{req.body}"
        end
      end
    end
  end
end

# http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each { |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable?(exe) && !File.directory?(exe)
    }
  end
  return false
end

#
# private boxes
#
def private?(boxname)
  proprietary_os_list = %w(macosx sles solaris windows)
  proprietary_os_list.any? { |p| boxname.include?(p) }
end
