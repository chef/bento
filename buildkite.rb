#!/usr/bin/env ruby

git_output = `git log -m -1 --name-only --pretty=format:%n`

# TODO: decide what, if anything, is rebuilt if bin/bento, buildkite.rb, scripts/common change.
changed_files = git_output.split("\n").reject { |t| t.empty? || t.include?("gitignore") || t.include?("dummy_metadata") || t.include?("bin/bento") || t.include?("buildkite.rb") || t.include?("scripts/common") || t.include?(".md") }

# Compile the list of platforms whose boxes will be rebuilt.
buildlist = []

# If OS-specific scripts have changed, rebuild all boxes associated with that OS.
family = changed_files.select { |b| b.include?("scripts") || b.include?("floppy") || b.include?("http") }
unless family.empty?
  all_templates = `ls *.json`.split("\n")

  family.each do |f|
    buildlist.concat(all_templates.collect { |a| a if a.include?(f.split("/")[1]) }.reject { |a| a.nil? })
  end
end

buildlist.concat(changed_files.select { |b| b.include?(".json") })
buildlist.uniq!
buildlist.collect! { |b| b.gsub!(".json", "") }
system "bundle exec rake do_all[#{buildlist.join(',')}]"
