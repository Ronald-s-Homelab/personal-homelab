include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = format(
    "%s/%s/modules/mikrotik/ppp/client///",
    get_repo_root(),
    "iac/terraform"
  )
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "routeros" {
  hosturl        = "https://mikrotik.ronaldmiranda.com.br"
  insecure       = "true"
}

EOF
}

locals {
  input = <<EOT
pppoe_conn:
  pppoe-ibranet:
    interface: ether1
    username: ${get_env("IBRANET_USER")}
    password: ${get_env("IBRANET_PASS")}
EOT
}

inputs = yamldecode(local.input)
