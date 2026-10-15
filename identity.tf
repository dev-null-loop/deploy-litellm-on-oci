module "iam_policies" {
  source         = "git@github.com:dev-null-loop/oci_identity//policy"
  for_each       = local.iam_policies
  compartment_id = var.compartment_ids[each.value.compartment]
  description    = each.value.description
  name           = each.value.name
  statements     = each.value.statements
}

