locals {
  module_dir = split("/", get_terragrunt_dir())[length(split("/", get_terragrunt_dir())) - 1]

  default_vpc_values = lookup(
    yamldecode(file(find_in_parent_folders("vars/defaults.yaml"))), "vpc_default", {}
  )
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = "ronald-s-homelab-terragrunt-states"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "ronald-s-homelab-table"
  }
}
generate provider {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = var.region
}
EOF
}

inputs = yamldecode(file(find_in_parent_folders("vars/region.yaml")))
