variable "nat_rules" {
  type = object({
    udp = list(object({
      name = string
      port = string
    }))
    tcp = list(object({
      name = string
      port = string
    }))
  })
}

variable "nat_address" {
  type = string
}
