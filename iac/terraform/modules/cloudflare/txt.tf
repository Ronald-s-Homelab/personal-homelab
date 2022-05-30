resource "cloudflare_record" "txt" {
  for_each        = { for k in compact([for k, v in var.txt_records : v.enabled ? k : ""]) : k => var.txt_records[k] }
  zone_id         = var.zone_id
  name            = each.value.name
  value           = each.value.value
  type            = "TXT"
  ttl             = try(each.value.ttl, 300)
  allow_overwrite = true
}
