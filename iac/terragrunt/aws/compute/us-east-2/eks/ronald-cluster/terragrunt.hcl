include "root" {
  path   = find_in_parent_folders()
  expose = true
}

terraform {
  source = format(
    "%s/%s/modules/aws/compute/eks///",
    get_repo_root(),
    "iac/terraform"
  )
}

locals {
  cluster_spec = yamldecode(file(find_in_parent_folders("vars/eks.yaml")))

  default_config = merge(
    { cluster_name = basename(get_terragrunt_dir()) },
    yamldecode(file(find_in_parent_folders("vars/defaults.yaml")))
  )

  nodepool_spec = {
    node_groups : { for k, v in local.cluster_spec.node_groups : k => merge(local.default_config.default_node_spec, v) }
  }
}

inputs = merge(local.default_config, local.cluster_spec, local.nodepool_spec)
