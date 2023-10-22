variable "security_rules" {
  type = map(object({
    description = optional(string)
    vpc_name    = string

    ingress_cidr = list(object({
      from_port   = optional(string)
      to_port     = optional(string)
      rule        = optional(string)
      protocol    = string
      description = string
      cidr_blocks = string
    }))

    outbound_cidr = optional(list(object({
      from_port   = optional(string)
      to_port     = optional(string)
      rule        = optional(string)
      protocol    = optional(string)
      description = string
      cidr_blocks = string
    })), [])
  }))
}

variable "region" {
  type = string
}
