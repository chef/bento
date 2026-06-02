# Bento Repository - Agent Instructions

This repository contains the Bento project, which provides:
1. **Ruby CLI Wrapper**: A Ruby gem (`bento`) that wraps Hashicorp Packer for building Vagrant boxes
2. **Packer Templates**: HCL-based Packer templates for building Vagrant base boxes across multiple operating systems and providers

## Repository Overview

### Ruby Component (CLI Wrapper)
- **Language**: Ruby 3.0+
- **Main Executable**: `bin/bento`
- **Library Code**: `lib/bento/`
- **Key Features**: Build, test, upload, list, and normalize Vagrant boxes
- **Dependencies**: mixlib-shellout, Packer, Vagrant

### Packer Component (Box Definitions)
- **Language**: HCL (HashiCorp Configuration Language)
- **Templates Directory**: `packer_templates/`
- **OS Variable Files**: `os_pkrvars/` (organized by OS family)
- **Supported Providers**: VirtualBox, VMware, Parallels, UTM, QEMU, Hyper-V
- **Supported Architectures**: x86_64, aarch64

## Code Change Requirements

### For ALL Changes to This Repository:

#### 1. Linting Requirements
Before committing any changes, you **MUST** run the following linters based on the files modified:

**Ruby Files** (`*.rb`, `Rakefile`, `*.gemspec`):
```bash
bundle install
bundle exec cookstyle -a .
```

**Markdown Files** (`*.md`):
```bash
# Markdown linting is performed via GitHub Actions
# Local testing not required but verify links work
```

**YAML Files** (`*.yml`, `*.yaml`):
```bash
# YAML linting is performed via GitHub Actions
# Ensure valid YAML syntax
```

**Shell Scripts** (`*.sh`):
```bash
shellcheck *.sh
```

**PowerShell Scripts** (`*.ps1`):
```bash
# PowerShell linting is performed via GitHub Actions
```

**Packer Templates** (`*.pkr.hcl`, `*.pkrvars.hcl`):
```bash
cd /path/to/bento
packer init -upgrade ./packer_templates
packer validate -var-file=os_pkrvars/<os>/<template>.pkrvars.hcl ./packer_templates
```

**All Packer Templates (Comprehensive Validation)**:
```bash
bundle exec rake validate
```

#### 2. Testing Requirements

**For Ruby Code Changes**:
```bash
# Install all dependencies (includes test-kitchen, kitchen-vagrant, and rspec)
bundle install

# Run the RSpec unit test suite
bundle exec rspec
# or equivalently:
bundle exec rake spec
# (bundle exec rake also runs spec by default)

# Run the bento CLI commands to verify functionality
bento list
bento build --dry-run os_pkrvars/<test-template>.pkrvars.hcl
```

**RSpec test suite** is located in `spec/` and covers all library modules:
- `spec/bento/common_spec.rb` — Common module helpers
- `spec/bento/buildmetadata_spec.rb` — BuildMetadata
- `spec/bento/providermetadata_spec.rb` — ProviderMetadata
- `spec/bento/packerexec_spec.rb` — PackerExec
- `spec/bento/runner_spec.rb` — BuildRunner
- `spec/bento/test_spec.rb` — TestRunner
- `spec/bento/upload_spec.rb` — UploadRunner

**For Packer Template Changes**:
```bash
# Validate the specific template
packer validate -var-file=os_pkrvars/<os>/<modified-template>.pkrvars.hcl ./packer_templates

# If possible, run a test build (requires hypervisor)
bento build os_pkrvars/<os>/<modified-template>.pkrvars.hcl

# Test with kitchen (if applicable)
bento test
```

#### 3. Documentation Updates

**README.md** - Update if:
- Adding new features to the bento CLI
- Changing CLI command syntax or options
- Adding/removing supported operating systems
- Modifying build requirements or prerequisites
- Changing installation instructions

**CHANGELOG.md** - Update for:
- **ALL user-facing changes** (bug fixes, features, breaking changes)
- New OS support or version updates
- Provider support changes (VirtualBox, VMware, etc.)
- Ruby gem version changes
- Template modifications affecting builds

**Format for CHANGELOG.md**:
```markdown
## Builds for version <VERSION>

[Add/update the build matrix table showing supported OS and providers]

### Changes
- Added support for [OS Name] version [X.Y]
- Fixed [issue description]
- Updated [component] to improve [functionality]
- BREAKING: [description of breaking change]
```

**TESTING.md** - Update if:
- Changing test procedures
- Adding new test requirements
- Modifying how `bento test` works

## Key Files to Understand

### Ruby Codebase
- `lib/bento/cli.rb` - Command-line interface definitions
- `lib/bento/runner.rb` - Build orchestration logic
- `lib/bento/packerexec.rb` - Packer command execution
- `lib/bento/test.rb` - Test kitchen integration (uses Kitchen Ruby API directly via `require 'kitchen'`; no shell-out)
- `lib/bento/upload.rb` - Vagrant Cloud upload logic
- `lib/bento/buildmetadata.rb` - Metadata generation
- `bento.gemspec` - Gem specification and dependencies (`test-kitchen` and `kitchen-vagrant` are runtime deps)
- `spec/` - RSpec unit tests for all library modules
- `.rspec` - RSpec configuration (documentation format, color output)

### Packer Templates
- `packer_templates/pkr-variables.pkr.hcl` - Variable definitions
- `packer_templates/pkr-sources.pkr.hcl` - Provider source configurations
- `packer_templates/pkr-builder.pkr.hcl` - Build orchestration
- `packer_templates/pkr-plugins.pkr.hcl` - Required Packer plugins
- `os_pkrvars/<os>/<os>-<version>-<arch>.pkrvars.hcl` - OS-specific variables

### Configuration Files
- `builds.yml` - Build configuration (public boxes, architectures, exclusions)
- `Rakefile` - Build automation tasks

## Workflow for Code Changes

### 1. Before Making Changes
```bash
# Ensure dependencies are installed
bundle install
packer init -upgrade ./packer_templates
```

### 2. During Development
```bash
# For Ruby changes: run cookstyle frequently
bundle exec cookstyle -a .

# For Packer changes: validate as you go
packer validate -var-file=os_pkrvars/<os>/<template>.pkrvars.hcl ./packer_templates
```

### 3. Before Committing
```bash
# Run all linters for modified file types
bundle exec cookstyle -a .  # Ruby files
shellcheck *.sh              # Shell scripts
bundle exec rake validate    # All Packer templates

# Update documentation
# - Update CHANGELOG.md with your changes
# - Update README.md if adding features or changing usage
# - Verify all documentation is accurate
```

### 4. Commit Message Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**: feat, fix, docs, style, refactor, test, chore
**Scopes**: cli, packer, templates, ubuntu, windows, etc.

**Examples**:
```
feat(templates): add Ubuntu 25.10 support

- Add os_pkrvars for Ubuntu 25.10 x86_64 and aarch64
- Update builds.yml to include new version
- Add to CHANGELOG.md build matrix

Closes #123
```

```
fix(cli): correct memory allocation for virtualbox builds

The --mem option was not being passed correctly to packer.
Fixed argument handling in packerexec.rb.
```

## Common Tasks

### Adding a New OS Template
1. Create `os_pkrvars/<os>/<os>-<version>-<arch>.pkrvars.hcl`
2. Validate: `packer validate -var-file=os_pkrvars/<os>/<new-template>.pkrvars.hcl ./packer_templates`
3. Update `builds.yml` if the OS should be public
4. Update `CHANGELOG.md` with the new OS in the build matrix
5. Update `README.md` if it's a significant addition
6. Run: `bundle exec rake validate` to ensure all templates still validate

### Modifying the Ruby CLI
1. Edit files in `lib/bento/`
2. Run unit tests: `bundle exec rspec`
3. Run linter: `bundle exec cookstyle -a .`
4. Test: `gem build bento.gemspec && gem install bento-*.gem`
5. Verify: `bento list`, `bento build --dry-run <template>`
6. Update `README.md` if CLI usage changes
7. Update `CHANGELOG.md` with the feature or fix

### Updating Packer Templates
1. Edit `packer_templates/*.pkr.hcl`
2. Validate: `bundle exec rake validate`
3. Test with a sample build: `bento build os_pkrvars/ubuntu/ubuntu-24.04-x86_64.pkrvars.hcl`
4. Update `CHANGELOG.md` if behavior changes
5. Update `README.md` if new features are available

## Important Notes

- **Always run linters before committing** - CI will fail if linting errors exist
- **Keep CHANGELOG.md current** - It serves as the release notes
- **Test your changes** - Especially for Packer templates, validate before submitting
- **Documentation is code** - Outdated docs are bugs
- **Architecture awareness** - Many templates are architecture-specific (x86_64 vs aarch64)
- **Provider compatibility** - Not all OS/architecture combinations work with all providers
- **Build times** - Packer builds can take 30+ minutes; use `--dry-run` for quick validation
- **Vagrant Cloud** - The `bento upload` command publishes to https://app.vagrantup.com/bento

## CI/CD

The repository uses GitHub Actions for:
- Linting (YAML, JSON, XML, Shell, PowerShell, Markdown, Packer)
- Packer ISO URL validation
- Automated builds per provider and architecture
- PR validation

See `.github/workflows/` for workflow definitions.

## Resources

- Packer Documentation: https://www.packer.io/docs
- Vagrant Documentation: https://www.vagrantup.com/docs
- Chef Bento Boxes: https://app.vagrantup.com/bento
- Kitchen-Vagrant: https://github.com/test-kitchen/kitchen-vagrant
