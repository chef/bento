variable "box_basename" {
  type    = string
  default = "almalinux-9.0"
}

variable "build_directory" {
  type    = string
  default = "../../builds"
}



variable "git_revision" {
  type    = string
  default = "__unknown_git_revision__"
}

variable "guest_additions_url" {
  type    = string
  default = ""
}

variable "headless" {
  type    = string
  default = ""
}

variable "http_proxy" {
  type    = string
  default = "${env("http_proxy")}"
}

variable "https_proxy" {
  type    = string
  default = "${env("https_proxy")}"
}

variable "hyperv_generation" {
  type    = string
  default = "1"
}

variable "hyperv_switch" {
  type    = string
  default = "bento"
}

variable "iso_checksum" {
  type    = string
  default = "6617436f8f2ee5408ff448a4eedce4ce61e2fdb3153a646b875010256bc9fd6b"
}

variable "iso_name" {
  type    = string
  default = "AlmaLinux-9.0-x86_64-dvd.iso"
}

variable "ks_path" {
  type    = string
  default = "9/ks.cfg"
}

variable "memory" {
  type    = string
  default = "1024"
}

variable "mirror" {
  type    = string
  default = "https://repo.almalinux.org/almalinux"
}

variable "mirror_directory" {
  type    = string
  default = "9.0/isos/x86_64"
}

variable "name" {
  type    = string
  default = "almalinux-9.0"
}

variable "no_proxy" {
  type    = string
  default = "${env("no_proxy")}"
}

variable "qemu_display" {
  type    = string
  default = "none"
}

variable "template" {
  type    = string
  default = "almalinux-9.0-x86_64"
}

variable "version" {
  type    = string
  default = "TIMESTAMP"
}
