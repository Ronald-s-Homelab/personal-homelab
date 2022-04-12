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
  }
}
EOF
}
