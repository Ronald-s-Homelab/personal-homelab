variable "a_records" {
  type = map(object({
    enabled = bool
    name    = string
    value   = string
    ttl     = string
  }))
  default = {}
}

variable "mx_records" {
  type = map(object({
    enabled  = bool
    name     = string
    value    = string
    priority = number
    ttl      = number
  }))
  default = {}
}

variable "txt_records" {
  type = map(object({
    enabled = bool
    name    = string
    value   = string
    ttl     = number
  }))
  default = {}
}

variable "cname_records" {
  type = map(object({
    enabled = bool
    name    = string
    value   = string
  }))
  default = {}
}

variable "zone_id" {
  type = string
}

variable CLOUDFLARE_EMAIL {
  type = string
}
variable CLOUDFLARE_API_KEY {
  type = string
}
