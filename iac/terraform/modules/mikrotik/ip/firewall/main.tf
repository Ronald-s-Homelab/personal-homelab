data "routeros_ip_addresses" "ip_addresses" {}


locals {
  if_public_ip = trimsuffix([for k, v in data.routeros_ip_addresses.ip_addresses.addresses : v.address if v.interface == "pppoe-ibranet"][0], "/32")
}

resource "routeros_ip_firewall_nat" "dstnat" {
  for_each     = { for k, v in flatten([for k, v in var.nat_rules : [for kk, vv in v : merge(vv, { proto : k })]]) : format("%s-%s-%s", v.name, v.port, v.proto) => v }
  action       = "dst-nat"
  chain        = "dstnat"
  comment      = each.value.name
  dst_port     = each.value.port
  protocol     = each.value.proto
  dst_address  = local.if_public_ip
  to_addresses = var.nat_address
  to_ports     = each.value.port
}
