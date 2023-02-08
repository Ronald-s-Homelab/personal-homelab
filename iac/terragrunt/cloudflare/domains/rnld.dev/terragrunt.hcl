include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = "git@github.com:cloudposse/terraform-cloudflare-zone.git"
}

locals {
  records = yamldecode(file(find_in_parent_folders("vars/${include.root.locals.module_dir}.yaml"))).records
  enabled_records = [ for i in local.records: i if try(i.enabled, false)]
}
inputs = merge(
  yamldecode(file(find_in_parent_folders("vars/${include.root.locals.module_dir}.yaml"))),
  { records = local.enabled_records }
)
