#!/usr/bin/env ruby

require 'json'
require 'net/http'
require 'uri'

BUILDKITE_ACCESS_TOKEN = ENV['BUILDKITE_ACCESS_TOKEN']
BUILDKITE_PROJECT = ENV['BUILDKITE_PROJECT'] ||= 'bento'
BUILDKITE_ORGANIZATION = ENV['BUILDKITE_ORGANIZATION_SLUG'] ||= 'chef'
IGNORED_FILES = %w(
  gitignore
  dummy_metadata
  bin/bento
  buildkite.rb
  scripts/common
  .md
).freeze

def buildkite_api_uri(args = {})
  raise Exception.new('Missing project argument') if args[:project].nil?
  raise Exception.new('Missing endpoint argument') if args[:endpoint].nil?

  URI::HTTPS.build(
    host:   'api.buildkite.com',
    path:   "/v2/organizations/#{BUILDKITE_ORGANIZATION}/pipelines/#{args[:project]}/#{args[:endpoint]}",
    query:  "access_token=#{BUILDKITE_ACCESS_TOKEN}"
  )
end

# Returns an array of builds hashes for the environment defined project.
def buildkite_builds
  response = Net::HTTP.get_response(
      buildkite_api_uri(project: BUILDKITE_PROJECT, endpoint: 'builds')
  )

  if response.code.to_i >= 400
    raise Exception.new("Unexpected response from BuildKite API: #{response.code_type}")
  else
    JSON.parse(response.body)
  end
end

# Returns a string
def last_passed_build_git_hash
  git_hash = ''

  buildkite_builds.map do |build|
    if build['state'] == 'passed'
      git_hash = build['commit']
      break
    end
  end

  if git_hash.empty?
    raise Exception.new('Unable to determine the commit hash of the last successful build.')
  else
    git_hash
  end
end


# Return an array of files changed since the last successful build.
# Sorry for the long function name.
def changed_files_since_last_passed_build
  # Cache fileset so we don't need to regenerate the result each time.
  @changed_files_since_last_passed_build ||= begin
    # `rev-list commit_x..HEAD` shows the commit hashes for each commit from a
    # given commit to the current HEAD.
    # `--objects` shows the actual files which have changed in the series of
    # commits.
    # We strip the commit IDs via awk because its cheap and a lazy way to get only
    # the data back we need.
    objects = `git rev-list #{last_passed_build_git_hash}..HEAD  --objects | awk '{print $2}'`.split.uniq
    # Only return objects which are files, or files with a path.
    objects.select { |object| File.file?(object) && !IGNORED_FILES.include?(object) }
  end
end

# Compile the list of platforms whose boxes will be rebuilt.
buildlist = []

# TODO: decide what, if anything, is rebuilt if bin/bento, buildkite.rb, scripts/common change.
# This expects the input array to only contain files and paths to files.
# eg: [".travis.yml", "CHANGELOG.md","README.md", "debian-8.3-amd64.json"]
# If OS-specific scripts have changed, rebuild all boxes associated with that OS.
family = changed_files_since_last_passed_build.select { |b| b.include?('scripts') || b.include?('floppy') || b.include?('http') }
require 'pry'; binding.pry

unless family.empty?
  all_templates = Dir.glob('*.json')

  family.each do |f|
    buildlist.concat(all_templates.collect { |a| a if a.it nclude?(f.split('/')[1]) }.reject { |a| a.nil? })
  end
end

buildlist.concat(changed_files_since_last_passed_build.select { |b| b.include?('.json') })
buildlist.uniq!
buildlist.collect! { |b| b.gsub!('.json', '') }
system "bundle exec rake do_all[#{buildlist.join(',')}]"
