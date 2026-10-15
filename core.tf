module "vcns" {
  source         = "git@github.com:dev-null-loop/oci_core//vcn"
  for_each       = var.vcns
  cidr_blocks    = each.value.cidr_blocks
  compartment_id = var.compartment_ids[each.value.compartment]
  display_name   = each.value.display_name
  dns_label      = each.value.dns_label
}

module "internet_gateways" {
  source         = "git@github.com:dev-null-loop/oci_core//internet_gateway"
  for_each       = var.internet_gateways
  compartment_id = var.compartment_ids[each.value.compartment]
  display_name   = each.value.display_name
  enabled        = each.value.enabled
  vcn_id         = module.vcns[each.value.vcn].id
}

module "nat_gateways" {
  source         = "git@github.com:dev-null-loop/oci_core//nat_gateway"
  for_each       = var.nat_gateways
  compartment_id = var.compartment_ids[each.value.compartment]
  display_name   = each.value.display_name
  vcn_id         = module.vcns[each.value.vcn].id
}

module "service_gateways" {
  source         = "git@github.com:dev-null-loop/oci_core//service_gateway"
  for_each       = var.service_gateways
  compartment_id = var.compartment_ids[each.value.compartment]
  display_name   = each.value.display_name
  service_id     = local.services[each.value.service].id
  vcn_id         = module.vcns[each.value.vcn].id
}

module "route_tables" {
  source         = "git@github.com:dev-null-loop/oci_core//route_table"
  for_each       = local.route_tables
  compartment_id = var.compartment_ids[each.value.compartment]
  display_name   = each.value.display_name
  route_rules    = each.value.route_rules
  vcn_id         = module.vcns[each.value.vcn].id
}

module "security_lists" {
  source         = "git@github.com:dev-null-loop/oci_core//security_list"
  for_each       = local.security_lists
  compartment_id = var.compartment_ids[each.value.compartment]
  display_name   = each.value.display_name
  egress_rules   = each.value.egress_rules
  ingress_rules  = each.value.ingress_rules
  vcn_id         = module.vcns[each.value.vcn].id
}

module "subnets" {
  source                     = "git@github.com:dev-null-loop/oci_core//subnet"
  for_each                   = var.subnets
  cidr_block                 = each.value.cidr_block
  compartment_id             = var.compartment_ids[each.value.compartment]
  display_name               = each.value.display_name
  dns_label                  = each.value.dns_label
  prohibit_internet_ingress  = each.value.prohibit_internet_ingress
  prohibit_public_ip_on_vnic = each.value.prohibit_public_ip_on_vnic
  route_table_id             = each.value.route_table == null ? null : module.route_tables[each.value.route_table].id
  security_list_ids          = length(each.value.security_lists) == 0 ? null : [for name in each.value.security_lists : module.security_lists[name].id]
  vcn_id                     = module.vcns[each.value.vcn].id
}

module "nsgs" {
  source         = "git@github.com:dev-null-loop/oci_core//network_security_group"
  for_each       = var.nsgs
  compartment_id = var.compartment_ids[each.value.compartment]
  display_name   = each.value.display_name
  vcn_id         = module.vcns[each.value.vcn].id
}

module "nsg_rules" {
  source                    = "git@github.com:dev-null-loop/oci_core//network_security_group_security_rule"
  for_each                  = local.nsg_rules
  description               = each.value.description
  destination               = each.value.destination
  destination_type          = each.value.destination_type
  direction                 = each.value.direction
  icmp_options              = each.value.icmp_options
  network_security_group_id = module.nsgs[each.value.nsg].id
  protocol                  = each.value.protocol
  rule_source               = each.value.source
  rule_source_type          = each.value.source_type
  stateless                 = each.value.stateless
  tcp_options               = each.value.tcp_options
  udp_options               = each.value.udp_options
}
