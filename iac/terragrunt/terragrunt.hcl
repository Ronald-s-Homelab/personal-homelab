locals {
  module_dir = split("/", get_terragrunt_dir())[length(split("/", get_terragrunt_dir())) - 1]
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
