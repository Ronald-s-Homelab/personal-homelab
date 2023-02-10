variable "repositories" {
  type = map(object({
    description = string
    visibility  = optional(string, "public")
  }))
}

variable "teams" {
  type = map(object({
    description = string
    parent      = optional(string)
    privacy     = optional(string, "closed")
    members = optional(map(object({
      role = string
    })), {})
  }))
}

variable "org_name" {
  type = string
}
