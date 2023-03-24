locals {
  inputs = yamldecode(file("../vars/infra.yaml"))
}

module "vcn" {
  source         = "../../modules/oracle/network"
  for_each       = local.inputs.vcn
  compartment_id = local.inputs.compartment_id

  vcn_cidr_block   = each.value.cidr_block
  vcn_display_name = each.key
  subnets          = each.value.subnets
  enabled_nat      = each.value.enabled_nat
  security_lists   = each.value.security_lists
}

module "compute" {
  for_each = local.inputs.compute.k8s
  source   = "../../modules/oracle/compute/k8s"

  name               = each.key
  compartment_id     = local.inputs.compartment_id
  kubernetes_version = each.value.version
  vcn_id             = module.vcn[each.value.vcn_name].vcn_id
  network_conf       = each.value.network_conf

  subnets = {
    lb_subnet = module.vcn[each.value.vcn_name].subnet_ocid[each.value.lb_subnet]
    private   = module.vcn[each.value.vcn_name].subnet_ocid[each.value.private_subnet]
  }

  node_pool_config = each.value.node_pool_config

}

module "vms" {
  for_each = local.inputs.compute.vm
  source   = "../../modules/oracle/compute/vm"

  name           = each.key
  compartment_id = local.inputs.compartment_id
  shape          = each.value.shape
  subnet_id      = module.vcn[each.value.vcn_name].subnet_ocid[each.value.subnet_name]
  public         = each.value.public
  ssh_public_key = each.value.ssh_public_key

}
