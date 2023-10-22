include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = format(
    "%s/%s/modules/aws/networking/security///",
    get_repo_root(),
    "iac/terraform"
  )
}

inputs = yamldecode(file(find_in_parent_folders("vars/networking.yaml")))
