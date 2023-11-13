include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = format(
    "%s/%s/modules/mikrotik/ip/firewall///",
    get_repo_root(),
    "iac/terraform"
  )
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "routeros" {
  hosturl  = "https://mikrotik.ronaldmiranda.com.br"
  insecure = "false"
}

EOF
}

locals {
  firewall_spec = yamldecode(file(find_in_parent_folders("vars/firewall.yaml"))).port_fwd
}

inputs = merge(
  { nat_address : "192.168.88.20" },
  local.firewall_spec
)
