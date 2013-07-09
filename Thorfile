require 'rubygems'
require 'bundler/setup'
require 'veewee'
require 'vagrant'

module Bento
  class Box < Thor
    include Thor::Actions

    desc 'create NAME', 'Create a Vagrant Box.'
    long_desc <<-LONGDESC
      A simple command to use bento definitions to build and export 
      a vagrant box and optionally add it to vagrant.

      The NAME operand sepecifies what your box will be called. A NAME.box
      file will be created in the current directory.

      The --definition option provides the name of a bento definition
      (in ./definitions) or the path to any other definition to use 
      for creating the box. If no definition is specified, the NAME operand
      is assumed to also be the name of a definition in ./definitions.

      The --provider option specifies the provider of your vagrant box
      i.e virtualbox or vmware_fusion. The default is virtualbox. This provider
      must be available on the machine where this command is run and will be
      used to create the box.

      The --iso_dir option specifies in which directory to download the .iso
      files for the operating system that will be installed.

      The -a, --add flag adds the box to vagrant after it is built and exported.

      The -f, --force flag forces an overwrite if a box with this name
      already exists.

      The -c, --clean flag deleates the exported .box file.

      The --nogui flag hides provider GUI while creating the box.

      EXAMPLES:

      >$ thor bento:box create debian-7.1.0

      >$ thor bento:box create -fac debian-7.1.0

      >$ thor bento:box create debian-7.1.0
              --provider=vmware_fusion

      >$ thor bento:box create mydebianbox
              --definition=debian-7.1.0

      >$ thor bento:box create mydebianbox 
              --definition=../mydefinitions/debian-7.1.0

      >$ thor bento:box create debian-7.1.0
              --iso-dir=../my_iso_cache

      >$ echo debian-7.1.0 centos-6.4 ubuntu-12.04 sles-11-sp2
              | xargs -n1 -I {} thor bento:box create {}

      >$ echo debian-7.1.0 centos-6.4 ubuntu-12.04 sles-11-sp2
              | tr ' ' '\\n'
              | parallel --delay 20 thor bento:box create -fac {}

    LONGDESC

    method_option :definition,
      :desc => 'Path to a Veewee definition.'

    method_option :provider,
      :default => 'virtualbox',
      :desc => 'Virtual Machine provider [virtualbox|vmware_fusion]'

    method_option :iso_dir,
      :default => 'iso',
      :desc => 'Directory to download .iso files in.'

    method_option :force,
      :aliases => '-f',
      :type => :boolean,
      :default => false,
      :lazy_default => true,
      :desc => 'Overwrite if the box already exists.'

    method_option :add,
      :aliases => '-a',
      :type => :boolean,
      :default => false,
      :lazy_default => true,
      :desc => 'Add the box to vagrant.'

    method_option :clean,
      :aliases => '-c',
      :type => :boolean,
      :default => false,
      :lazy_default => true,
      :desc => 'Delete the exported .box file.'

    method_option :nogui,
      :type => :boolean,
      :default => false,
      :lazy_default => true,
      :desc => 'Dot\'t display provider GUI when building this box.'

    def create(name)

      # options is frozen by thor
      # dup, so we can add/modify options before passing them to Veewee
      opts = options.dup

      # if no definition is specified, use name as definition
      opts['definition'] = opts['definition'] || name

      # if the definition is a path, break into definition_dir and definition,
      # if it is not a path then definition_dir is by default ./definitions
      if File.split(opts['definition'])[0] != "."
        definition = opts['definition']
        opts['definition_dir'] = File.dirname(File.absolute_path(definition))
        opts['definition'] = File.basename(definition)
      end

      # support both vmfusion/vmware_fusion to be consitant with vagrant
      opts['provider'] = 'vmfusion' if opts['provider'] == 'vmware_fusion'

      # use albsolte path for iso_dir, fusion does not like relative paths
      opts['iso_dir'] = File.absolute_path(opts['iso_dir'])
      opts['auto'] = true #auto answers

      # create a new veewee enviornment and make veewee output to shell
      veewee = Veewee::Environment.new(opts)
      veewee.ui = ::Veewee::UI::Shell.new(veewee, shell)

      # find the definition and build the box
      box = veewee.providers[opts['provider']].get_box(opts['definition'])
      box.build(opts)

      # export the box 
      if opts['provider'] == 'vmfusion'
        opts['export_type'] = 'vagrant' # ensure fusion exports .box not .ova
        box.export_vmfusion(opts)
      else
        box.export_vagrant(opts) # for virtualbox and kvm
      end

      # store the path of the exported .box file
      export = File.join(veewee.cwd, opts['definition'] + '.box')

      # destroy the box, doesn't work in fusion, for now
      # https://github.com/thbishop/fission/issues/23
      # TODO: remove the condition when veewee is updated for newer fission
      box.destroy unless opts['provider'] == 'vmfusion'

      # add the exported box to vagrant, if requested
      if opts['add']
        puts "Adding #{export} to vagrant"
        Vagrant::Environment.new.boxes.add(export, name, nil, opts['force'])
      end

      # delete the exported .box file, if requested, or rename it.
      if opts['clean']
        puts "Deleting #{export}"
        File.delete(export)
      else
        File.rename(export, File.join(veewee.cwd, name + '.box'))
      end
    end

  end
end