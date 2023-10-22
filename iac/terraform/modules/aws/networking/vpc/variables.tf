variable "region" {
  type = string
}

variable "vpc" {
  type = map(object({
    cidr                          = string
    secondary_cidr                = optional(string)
    azs                           = list(string)
    public_subnets                = optional(list(string), null)
    private_subnets               = optional(list(string))
    endpoints_enabled             = optional(bool, true)
    enable_dns_hostnames          = optional(bool, false)
    map_public_ip_on_launch       = optional(bool, true)
    enable_dns_support            = optional(bool, false)
    enable_nat_gateway            = optional(bool, false)
    single_nat_gateway            = optional(bool, false)
    one_nat_gateway_per_az        = optional(bool, false)
    manage_default_security_group = optional(bool, false)
    manage_default_network_acl    = optional(bool, false)
  }))
}
