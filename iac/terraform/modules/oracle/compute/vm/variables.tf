variable "name" {
  type = string
}

variable "compartment_id" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "public" {
  type = bool
}

variable "preserve_boot_volume" {
  type    = bool
  default = false
}

variable "shape" {
  type = object({
    shape   = string
    ocpus   = number
    mem_gbs = number
  })
}

variable "subnet_id" {
  type = string
}
