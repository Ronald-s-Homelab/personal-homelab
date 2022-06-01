include {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_path_to_repo_root()}/iac/terraform/modules/proxmox/lxc"
}

inputs = merge(
  yamldecode(file(find_in_parent_folders("vars/vms.yaml"))),
  { defaults = yamldecode(file(find_in_parent_folders("defaults/vms.yaml"))) }
)
