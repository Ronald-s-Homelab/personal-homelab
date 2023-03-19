resource "github_branch_default" "default" {
  for_each   = var.repositories
  repository = github_repository.repo[each.key].name
  branch     = each.value.default_branch
}

resource "github_repository" "repo" {
  for_each = var.repositories

  name        = each.key
  description = each.value.description
  visibility  = each.value.visibility
  auto_init   = each.value.auto_init

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

resource "github_repository_file" "readme" {
  for_each = { for k, v in var.repositories : k => v.projects_readme if v.projects_readme != false }

  repository          = github_repository.repo[each.key].name
  branch              = "main"
  file                = "README.md"
  content             = templatefile("../tmpls/README.md.template", yamldecode(file("../vars/projects.yaml")))
  commit_message      = "Adiciona/Remove membro projeto (Terraform)"
  commit_author       = "Terraform"
  commit_email        = "terraform-github@ronaldmiranda.com.br"
  overwrite_on_create = true
}
