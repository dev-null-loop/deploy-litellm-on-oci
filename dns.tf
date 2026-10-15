module "dns_zones" {
  source         = "git@github.com:dev-null-loop/oci_dns//zone"
  for_each       = var.dns_zones
  compartment_id = var.compartment_ids[each.value.compartment]
  dnssec_state   = each.value.dnssec_state
  name           = each.value.name
  scope          = each.value.scope
  zone_type      = each.value.zone_type
}

module "dns_records" {
  source          = "git@github.com:dev-null-loop/oci_dns//rrset"
  for_each        = local.dns_records
  domain          = each.value.domain
  items           = each.value.items
  rtype           = each.value.rtype
  zone_name_or_id = module.dns_zones[each.value.zone].id
}

