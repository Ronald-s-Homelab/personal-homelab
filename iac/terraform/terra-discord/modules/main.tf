resource "discord_server" "server" {
  name   = var.name
  region = var.region

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      verification_level
    ]
  }
}

module "members" {
  for_each = var.members
  source   = "./members"

  server_id     = discord_server.server.id
  username      = split("#", each.key)[0]
  discriminator = split("#", each.key)[1]
  teams         = each.value.teams
}

module "tags" {
  source = "./tags"

  server_id = discord_server.server.id
  roles     = var.roles
  members   = local.membersPerms

  depends_on = [
    module.members
  ]
}

resource "discord_invite" "invite" {

  channel_id = var.invite_ch_id
  max_age    = 0
}

