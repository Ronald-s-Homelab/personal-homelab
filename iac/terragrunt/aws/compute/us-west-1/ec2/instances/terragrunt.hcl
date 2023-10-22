include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = format(
    "%s/%s/modules/aws/compute/ec2/instance//",
    get_repo_root(),
    "iac/terraform"
  )
}

locals {
  instances = yamldecode(file(find_in_parent_folders("vars/instances.yaml")))
}

inputs = local.instances
