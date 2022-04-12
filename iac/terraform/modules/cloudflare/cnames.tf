resource "cloudflare_record" "cname" {
  for_each = { for k in compact([for k, v in var.cname_records : v.enabled ? k : ""]) : k => var.cname_records[k] }
  zone_id  = var.zone_id
  name     = each.value.name
  value    = each.value.value
  type     = "CNAME"
}
