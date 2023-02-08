data "discord_member" "member" {
  server_id     = var.server_id
  username      = var.username
  discriminator = var.discriminator
}

output "members" {
  value = data.discord_member.member
}
