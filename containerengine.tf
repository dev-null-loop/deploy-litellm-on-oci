module "clusters" {
  source                      = "git@github.com:dev-null-loop/oci_containerengine//cluster"
  for_each                    = local.clusters
  cluster_pod_network_options = each.value.cluster_pod_network_options
  compartment_id              = var.compartment_ids[each.value.compartment]
  endpoint_config             = each.value.endpoint_config
  kubernetes_version          = each.value.kubernetes_version
  name                        = each.value.name
  options                     = each.value.options
  type                        = each.value.type
  vcn_id                      = module.vcns[each.value.vcn].id
}

module "node_pools" {
  source              = "git@github.com:dev-null-loop/oci_containerengine//node_pool"
  for_each            = local.node_pools
  cluster_id          = module.clusters[each.value.cluster].id
  compartment_id      = var.compartment_ids[each.value.compartment]
  freeform_tags       = each.value.freeform_tags
  image_id            = each.value.image_id
  kubernetes_version  = each.value.kubernetes_version
  name                = each.value.name
  node_config_details = each.value.node_config_details
  node_shape          = each.value.node_shape
  node_shape_config   = each.value.node_shape_config
  node_source_details = each.value.node_source_details
  ssh_public_key      = each.value.ssh_public_key
}

module "addons" {
  source                           = "git@github.com:dev-null-loop/oci_containerengine//addon"
  for_each                         = local.addons
  addon_name                       = each.value.addon_name
  addon_version                    = each.value.addon_version
  cluster_id                       = module.clusters[each.value.cluster].id
  configurations                   = each.value.configurations
  override_existing                = each.value.override_existing
  remove_addon_resources_on_delete = each.value.remove_addon_resources_on_delete
}

