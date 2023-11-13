include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = format(
    "%s/%s/modules/mikrotik/dhcp/server///",
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
  insecure       = true
}
EOF
}

inputs = merge(
  yamldecode(file(find_in_parent_folders("vars/dhcp.yaml")))
)
