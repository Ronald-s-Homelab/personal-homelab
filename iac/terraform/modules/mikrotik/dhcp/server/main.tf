resource "routeros_ip_dhcp_server" "server" {
  for_each     = var.servers

  address_pool = each.value.address_pool
  interface    = each.value.interface
  name         = each.key
}

resource "routeros_ip_dhcp_server_lease" "dhcp_lease" {
  for_each    = var.leases

  address     = each.value
  mac_address = each.key
  lease_time  = "0s"
  server      = "defconf"
}
