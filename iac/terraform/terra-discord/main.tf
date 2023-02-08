provider "discord" {
  token = var.discord_bot_token
}

module "discord_server" {
  for_each = local.inputs
  source   = "./modules"

  # invite_ch_id = each.value.invite_ch_id
  members = each.value.members
  name    = each.key
  region  = each.value.region
  roles   = each.value.roles
}

output "servers" {
  value = module.discord_server
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
