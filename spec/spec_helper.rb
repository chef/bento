# frozen_string_literal: true

require 'json'
require 'fileutils'
require 'tmpdir'
require 'ostruct'

# Add lib to load path
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.disable_monkey_patching!
  config.warnings = true
  config.order = :random
  Kernel.srand config.seed
end

# Helper: build a minimal OpenStruct opts suitable for most runners
def build_opts(overrides = {})
  defaults = {
    debug: false,
    no_shared: false,
    provisioner: nil,
    regx: nil,
    md_json: nil,
    template_files: [],
    dry_run: false,
    metadata_only: false,
    on_error: nil,
    only: nil,
    except: nil,
    mirror: nil,
    headed: false,
    single: false,
    override_version: '202506.01.0',
    cpus: nil,
    mem: nil,
    vars: nil,
    var_files: nil,
    config: false,
  }
  OpenStruct.new(defaults.merge(overrides))
end
