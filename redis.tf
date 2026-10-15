module "redis_clusters" {
  source             = "git@github.com:dev-null-loop/oci_redis//redis_cluster"
  for_each           = var.redis_clusters
  cluster_mode       = each.value.cluster_mode
  compartment_id     = var.compartment_ids[each.value.compartment]
  display_name       = each.value.display_name
  node_count         = each.value.node_count
  node_memory_in_gbs = each.value.node_memory_in_gbs
  nsg_ids            = [for name in each.value.nsgs : module.nsgs[name].id]
  shard_count        = each.value.shard_count
  software_version   = each.value.software_version
  subnet_id          = module.subnets[each.value.subnet].id
}

module "redis_users" {
  source              = "git@github.com:dev-null-loop/oci_redis//oci_cache_user"
  for_each            = var.redis_users
  acl_string          = each.value.acl_string
  authentication_mode = each.value.authentication_mode
  compartment_id      = var.compartment_ids[each.value.compartment]
  description         = each.value.description
  name                = each.value.name
  status              = each.value.status
}

module "redis_cluster_user_attachments" {
  source           = "git@github.com:dev-null-loop/oci_redis//redis_cluster_attach_oci_cache_user"
  for_each         = local.redis_cluster_user_attachments
  oci_cache_users  = each.value.oci_cache_users
  redis_cluster_id = each.value.redis_cluster_id
}
