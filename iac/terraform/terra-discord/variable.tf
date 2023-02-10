locals {
  inputs = merge({
    discords = yamldecode(file("../vars/discords.yaml"))
    github   = yamldecode(file("../vars/github.yaml"))
  })
}

variable "DISCORD_BOT_TOKEN" {
  type = string
}
