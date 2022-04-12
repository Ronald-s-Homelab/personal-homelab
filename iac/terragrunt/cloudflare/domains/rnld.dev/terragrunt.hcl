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
  { zone_id = "b157ae325c6a0ba01fb86c6b16cfda5d" },
  yamldecode(file(find_in_parent_folders("vars/${include.backend.locals.module_dir}.yaml")))
)
