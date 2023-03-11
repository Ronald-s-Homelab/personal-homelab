variable "compartment_id" {
  type = string
}

variable "vcn_cidr_block" {
  type = string
}

variable "vcn_display_name" {
  type = string
}

variable "enabled_nat" {
  type = bool
}

variable "subnets" {
  type = map(object({
    cidr_block                 = string
    prohibit_internet_ingress  = optional(bool, false)
    prohibit_public_ip_on_vnic = optional(bool, false)
    security_lists             = optional(list(string), [])
    nat                        = optional(bool, false)
  }))
}

variable "security_lists" {
  type = map(object({
    egress = optional(list(object({
      dest             = optional(string, "0.0.0.0/0")
      proto            = optional(string, "all")
      destination_type = optional(string, "CIDR_BLOCK")

      icmp = optional(list(object({
        type = number
        code = number
      })), [])

      ports = optional(string, "")
    })), [])

    ingress = optional(list(object({
      source      = optional(string, "0.0.0.0/0")
      proto       = optional(string, "all")
      source_type = optional(string, "CIDR_BLOCK")

      icmp = optional(list(object({
        type = number
        code = number
      })), [])

      ports = optional(string, "")
    })), [])
  }))
}
