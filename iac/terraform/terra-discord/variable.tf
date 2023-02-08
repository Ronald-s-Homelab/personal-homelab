locals {
  inputs = yamldecode(file("input.yaml"))
}

variable "discord_bot_token" {
  type = string
}
