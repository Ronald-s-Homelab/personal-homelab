provider "discord" {
  token = var.DISCORD_BOT_TOKEN
}

module "discord_server" {
  for_each = local.inputs.discords
  source   = "./modules"

  invite_ch_id = each.value.invite_ch_id
  members      = each.value.members
  name         = replace(each.key, "_", " ")
  region       = each.value.region
  roles        = each.value.roles
}

module "github" {
  source = "../modules/github"

  org_name     = local.inputs.github.org_name
  repositories = local.inputs.github.repositories
  teams        = local.inputs.github.teams
}

output "invites" {
  value = {for k,v in module.discord_server: k => v.invites }
}

terraform {
  backend "s3" {
    bucket = "terraform"
    key    = "terra-discord/terraform.tfstate"

    endpoint                    = "https://minio.ronaldmiranda.com.br"
    region                      = "main"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
}
