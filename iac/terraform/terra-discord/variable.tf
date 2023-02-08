locals {
  inputs = yamldecode(file("input.yaml"))
}

variable "DISCORD_BOT_TOKEN" {
  type = string
}
