resource "github_repository" "repo" {
  for_each = var.repositories

  name        = each.key
  description = each.value.description
  visibility  = each.value.visibility

  lifecycle {
    ignore_changes = [
      has_downloads,
      has_issues,
      has_projects,
      has_wiki
    ]
  }
}

resource "github_team" "teams" {
  for_each = { for k, v in var.teams : k => v if v.parent == null }

  name        = each.key
  description = each.value.description
  privacy     = each.value.privacy
}

resource "github_team" "teams_with_parent" {
  for_each = { for k, v in var.teams : k => v if v.parent != null }

  name           = each.key
  description    = each.value.description
  privacy        = each.value.privacy
  parent_team_id = github_team.teams[each.value.parent].id

  depends_on = [
    github_team.teams
  ]
}

resource "github_team_membership" "some_team_membership" {
  for_each = merge([for k, v in var.teams :
    { for kk, vv in v.members : "${k}/${kk}" => {
      username = kk
      role     = vv.role
      team     = k
      parent   = v.parent
    } }
  ]...)

  team_id  = each.value.parent == null ? github_team.teams[each.value.team].id : github_team.teams_with_parent[each.value.team].id
  username = each.value.username
  role     = each.value.role
}
