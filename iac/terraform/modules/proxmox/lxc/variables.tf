terraform {
  # Optional attributes and the defaults function are
  # both experimental, so we must opt in to the experiment.
  experiments = [module_variable_optional_attrs]
}

variable "lxc" {
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

    bridge       = optional(string)
    macaddr      = optional(string)
    user         = optional(string)
    ipconfig     = optional(string)
    sshkeys      = optional(string)
    ostemplate   = optional(string)
    unprivileged = optional(bool)

    disk-size = optional(string)
  })
}
