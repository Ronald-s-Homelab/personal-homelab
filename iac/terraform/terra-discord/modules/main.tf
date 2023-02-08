resource "discord_server" "server" {
  name   = var.name
  region = var.region
}

resource "discord_text_channel" "temp_chat" {
  name                     = "temp_chat"
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  category                 = discord_category_channel.chatting.id
}

resource "discord_text_channel" "teste_fora" {
  name                     = "teste_fora"
  server_id                = discord_server.server.id
  sync_perms_with_category = false
  # category                 = discord_category_channel.conversa_fiada.id
}

resource "discord_category_channel" "chatting" {
  name      = "Chatting"
  server_id = discord_server.server.id
}

resource "discord_category_channel" "conversa_fiada" {
  name      = "conversa_fiada"
  server_id = discord_server.server.id

  depends_on = [
    discord_category_channel.chatting
  ]
}

# module "members" {
#   for_each = var.members
#   source   = "./members"

#   server_id     = discord_server.server.id
#   username      = split("#", each.key)[0]
#   discriminator = split("#", each.key)[1]
#   teams         = each.value.teams
# }

# module "tags" {
#   source = "./tags"

#   server_id = discord_server.server.id
#   roles     = var.roles
#   members   = local.membersPerms

#   depends_on = [
#     module.members
#   ]
# }

resource "discord_invite" "invite" {

  channel_id = discord_text_channel.temp_chat.id
  max_age    = 0
}

