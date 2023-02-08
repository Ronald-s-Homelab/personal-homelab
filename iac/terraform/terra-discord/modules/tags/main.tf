resource "discord_role" "role" {
  for_each = var.roles

  server_id   = var.server_id
  name        = each.key
  permissions = data.discord_permission.perm[each.key].allow_bits
  hoist       = each.value.config.hoist
  mentionable = each.value.config.mentionable
  position    = each.value.config.position
}

resource "discord_member_roles" "roles" {
  for_each = var.members

  user_id   = each.value.user_id
  server_id = var.server_id

  dynamic "role" {
    for_each = each.value.perms
    content {
      role_id = discord_role.role[role.value].id
    }
  }
}
