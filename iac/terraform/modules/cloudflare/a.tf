resource "cloudflare_record" "a" {
  for_each = { for k in compact([for k, v in var.a_records : v.enabled ? k : ""]) : k => var.a_records[k] }
  zone_id  = var.zone_id
  name     = each.value.name
  value    = each.value.value
  type     = "A"
  ttl      = each.value.ttl
}
