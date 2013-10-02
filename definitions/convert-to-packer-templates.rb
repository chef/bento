require 'json'

# Create Vanilla Image Templates
Dir.glob("*").each { |os| 
  unless os == "convert.rb" || os == "packer_cache"

    puts "Converting #{os}"
    `veewee-to-packer ./#{os}/definition.rb -o ../templates/#{os}`
    
    template = JSON.parse(File.read("../templates/#{os}/template.json"))

    # Save Provisionless Template
    template["post-processors"] = [ { "type" => "vagrant", "output" => "#{os}-{{.Provider}}.box"} ] 
    
    vanilla_image = File.open("../templates/#{os}/vanilla.json", "w")
    file.write(JSON.pretty_generate(template))
    file.close

    # Save Chef-Provisioned Template
    template["provisioners"].each { |provisioner|
      provisioner["override"].each { |provider|
        template[provisioner][provider]["execute_command"] = "echo 'vagrant'|sudo -S sh '{{.Path}}'; curl https://opscode.com/chef/install.sh | sudo bash"
      }
    }
    template["post-processors"] = [ { "type" => "vagrant", "output" => "#{os}-{{.Provider}}-with-chef.box"} ] 
    
    chef_image = File.open("../templates/#{os}/chef.json", "w")
    file.write(JSON.pretty_generate(template))
    file.close
  end
}
