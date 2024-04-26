# frozen_string_literal: true
require_relative 'lib/bento/version'

Gem::Specification.new do |s|
  s.name = 'bento'
  s.version = Bento::VERSION
  s.summary = 'Bento builds generic Vagrant boxes '
  s.description = s.summary
  s.license = 'Apache-2.0'
  s.author = 'Many many Chef employees over the years'
  s.email = 'oss@chef.io'
  s.homepage = 'https://github.com/chef/bento/'

  s.required_ruby_version = '>= 3.0'

  s.add_dependency 'mixlib-shellout', '>= 2.3.2'
  s.add_dependency 'test-kitchen'
  s.add_dependency 'kitchen-vagrant'

  s.bindir = 'bin'
  s.executables = %w(bento)

  s.require_path = 'lib'
  s.files = %w(LICENSE Gemfile) + Dir.glob('*.gemspec') + Dir.glob('lib/**/*')
end
