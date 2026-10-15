module "certificates" {
  source             = "git@github.com:dev-null-loop/oci_certificates_management//certificate"
  for_each           = var.certificates
  certificate_config = each.value.certificate_config
  certificate_rules  = each.value.certificate_rules
  compartment_id     = var.compartment_ids[each.value.compartment]
  description        = each.value.description
  name               = each.value.name
}

