module "waf_policies" {
  source                 = "git@github.com:dev-null-loop/oci_waf//web_app_firewall_policy"
  for_each               = var.waf_policies
  actions                = each.value.actions
  compartment_id         = var.compartment_ids[each.value.compartment]
  display_name           = each.value.display_name
  request_access_control = each.value.request_access_control
  request_rate_limiting  = each.value.request_rate_limiting
}

