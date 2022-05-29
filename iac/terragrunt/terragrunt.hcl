locals {
  module_dir = split("/", get_terragrunt_dir())[length(split("/", get_terragrunt_dir())) - 1]
}

generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "3.6.0"
    }
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.74.0"
    }
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.9.10"
    }
  }
}
EOF
}

remote_state {
  backend = "azurerm"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    resource_group_name  = "app-volume"
    storage_account_name = "ronaldterraformstates"
    container_name       = "states"
    key                  = "${path_relative_to_include()}/terraform.tfstate"
  }
}
