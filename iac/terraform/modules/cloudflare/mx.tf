resource "cloudflare_record" "mx" {
  for_each = { for k in compact([for k, v in var.mx_records : v.enabled ? k : ""]) : k => var.mx_records[k] }
  zone_id  = var.zone_id
  name     = each.value.name
  value    = each.value.value
  priority = each.value.priority
  type     = "MX"
  ttl      = each.value.ttl
}
