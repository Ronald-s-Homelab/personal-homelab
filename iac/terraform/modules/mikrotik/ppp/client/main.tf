variable "pppoe_conn" {
  type = map(object({
    interface = string
    username  = string
    password  = string
  }))
}

resource "routeros_interface_pppoe_client" "test" {
  for_each = var.pppoe_conn

  name              = each.key
  interface         = each.value.interface
  user              = each.value.username
  password          = each.value.password
  disabled          = false
  dial_on_demand    = true
  add_default_route = true
  use_peer_dns      = true
}
