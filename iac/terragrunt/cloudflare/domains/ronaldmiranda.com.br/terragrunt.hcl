include {
  path = find_in_parent_folders()
}

include "backend" {
  path   = "../backend.hcl"
  expose = true
}

terraform {
  source = "${get_path_to_repo_root()}/iac/terraform/modules/cloudflare"
}

inputs = merge(
  { zone_id = "d34b9b7f0a164010a0a262b8e5636a58" },
  yamldecode(file(find_in_parent_folders("vars/${include.backend.locals.module_dir}.yaml")))
)
