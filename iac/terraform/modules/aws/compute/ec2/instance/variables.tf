variable "instances" {
  type = map(object({
    type                   = string
    key_name               = string
    monitoring             = optional(bool, false)
    vpc_security_group_ids = optional(list(string), [])
    subnet_id              = string

    tags = optional(map(string), {})
  }))
}

variable "region" {
  type = string
}
