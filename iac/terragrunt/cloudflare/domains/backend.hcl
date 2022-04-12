locals {
  module_dir = split("/", get_terragrunt_dir())[length(split("/", get_terragrunt_dir())) - 1]
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "azurerm" {
    resource_group_name  = "app-volume"
    storage_account_name = "ronaldterraformstates"
    container_name       = "states"
    key                  = "cloudflare/${local.module_dir}/terraform.tfstate"
  }
}
EOF
}
