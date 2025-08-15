packer {
  required_version = ">= 1.7.0"
  required_plugins {
    cnspec = {
      version = ">= 10.0.0"
      source  = "github.com/mondoohq/cnspec"
    }
    hyperv = {
      version = ">= 1.0.3"
      source  = "github.com/hashicorp/hyperv"
    }
    ipsw = {
      version = ">= 0.1.5"
      source  = "github.com/torarnv/ipsw"
    }
    parallels = {
      version = ">= 1.1.6"
      source  = "github.com/parallels/parallels"
    }
    qemu = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/qemu"
    }
    utm = {
      version = ">= 0.3.3"
      source  = "github.com/naveenrajm7/utm"
    }
    vagrant = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/vagrant"
    }
    virtualbox = {
      version = ">= 1.0.3"
      source  = "github.com/hashicorp/virtualbox"
    }
    vmware = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/vmware"
    }
    windows-update = {
      version = ">= 0.14.1"
      source  = "github.com/rgl/windows-update"
    }
  }
}
