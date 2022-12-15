# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = "bento"
  s.version = "1.0"
  s.summary = "Bento builds generic Vagrant boxes "
  s.description = s.summary
  s.license = "Apache-2.0"
  s.author = "Many many Chef employees over the years"
  s.email = "oss@chef.io"
  s.homepage = "https://github.com/chef/bento/"

  s.required_ruby_version = ">= 2.6"

  s.add_dependency "mixlib-shellout", ">= 2.3.2"

  s.bindir = "bin"
  s.executables = %w{bento}

  s.require_path = "lib"
  s.files = %w{LICENSE Gemfile} + Dir.glob("*.gemspec") + Dir.glob("lib/**/*")
end
