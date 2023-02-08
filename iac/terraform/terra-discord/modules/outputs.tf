# output "members" {
#   value = local.members
# }

output "invites" {
  value = format("https://discord.gg/%s", discord_invite.invite.id)
}

# locals {
#   members = { for k, v in module.members : k => {
#     user_id = v.members.id
#     roles   = v.members.roles
#   } if v.members.in_server != null }
#   membersPerms = { for k, v in module.members : k => {
#     user_id = v.members.id
#     roles   = v.members.roles
#     perms   = var.members[k].teams
#   } if v.members.in_server != null }
# }
