terraform {
  # Optional attributes and the defaults function are
  # both experimental, so we must opt in to the experiment.
  experiments = [module_variable_optional_attrs]
}

variable "vms" {
  type = map(any)
}

variable "defaults" {
  type = object({
    desc        = optional(string)
    target_node = optional(string)
    clone       = optional(string)

    cores   = optional(number)
    sockets = optional(number)
    memory  = optional(number)

    macaddr  = optional(string)
    user     = optional(string)
    ipconfig = optional(string)
    sshkeys  = optional(string)

    disk-size = optional(string)
  })
}
