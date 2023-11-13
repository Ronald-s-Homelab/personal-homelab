variable "leases" {
  type = map(string)
}

variable "servers" {
  type = map(object({
    address_pool = string
    interface = string
  }))
}
