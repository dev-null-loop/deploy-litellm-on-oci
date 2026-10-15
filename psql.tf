module "db_systems" {
  source                      = "git@github.com:dev-null-loop/oci_psql//db_system"
  for_each                    = local.db_systems
  compartment_id              = var.compartment_ids[each.value.compartment]
  credentials                 = each.value.credentials
  db_version                  = each.value.db_version
  display_name                = each.value.display_name
  instance_count              = each.value.instance_count
  instance_memory_size_in_gbs = each.value.instance_memory_size_in_gbs
  instance_ocpu_count         = each.value.instance_ocpu_count
  management_policy           = each.value.management_policy
  network_details             = each.value.network_details
  shape                       = each.value.shape
  storage_details             = each.value.storage_details
}

