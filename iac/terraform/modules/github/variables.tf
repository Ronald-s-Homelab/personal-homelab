variable "repositories" {
  type = map(object({
    description     = string
    visibility      = optional(string, "public")
    default_branch  = optional(string, "main")
    auto_init       = optional(bool, false)
    projects_readme = optional(bool, false)
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

variable "privkey_gh_app" {
  type    = string
  default = ""
}
