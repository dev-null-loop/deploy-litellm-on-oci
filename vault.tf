module "vaults" {
  source         = "git@github.com:dev-null-loop/oci_kms//vault"
  for_each       = var.vaults
  compartment_id = var.compartment_ids[each.value.compartment]
  display_name   = each.value.display_name
  vault_type     = each.value.vault_type
}

module "keys" {
  source                   = "git@github.com:dev-null-loop/oci_kms//key"
  for_each                 = var.keys
  compartment_id           = var.compartment_ids[each.value.compartment]
  display_name             = each.value.display_name
  is_auto_rotation_enabled = each.value.is_auto_rotation_enabled
  key_shape                = each.value.key_shape
  management_endpoint      = module.vaults[each.value.vault].management_endpoint
  protection_mode          = each.value.protection_mode
}

module "secrets" {
  source                    = "git@github.com:dev-null-loop/oci_vault//secret"
  for_each                  = var.secrets
  compartment_id            = var.compartment_ids[each.value.compartment]
  description               = each.value.description
  enable_auto_generation    = each.value.enable_auto_generation
  key_id                    = module.keys[each.value.key].id
  secret_content            = each.value.secret_content
  secret_generation_context = each.value.secret_generation_context
  secret_name               = each.value.secret_name
  vault_id                  = module.vaults[each.value.vault].id
}

