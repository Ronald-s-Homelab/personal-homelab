include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = format(
    "%s/%s/modules/aws/networking/vpc///",
    get_repo_root(),
    "iac/terraform"
  )
}

inputs = {
  vpc = { for k, v in yamldecode(file(find_in_parent_folders("vars/networking.yaml"))).vpc :
    k => merge(include.root.locals.default_vpc_values, v)
  }
}
