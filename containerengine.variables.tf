variable "clusters" {
  description = "OKE clusters keyed by a stable symbolic name."
  type = map(object({
    compartment        = string
    name               = string
    kubernetes_version = string
    type               = optional(string, "ENHANCED_CLUSTER")
    vcn                = string
    cluster_pod_network_options = object({
      cni_type = string
    })
    endpoint_config = object({
      is_public_ip_enabled = optional(bool, false)
      nsgs                 = optional(list(string), [])
      subnet               = string
    })
    options = optional(object({
      service_lb_subnets = optional(list(string), [])
    }))
  }))
  default = {}
}

variable "node_pools" {
  description = "OKE managed node pools keyed by a stable symbolic name."
  type = map(object({
    cluster            = string
    compartment        = string
    freeform_tags      = optional(map(string), {})
    kubernetes_version = string
    name               = string
    node_shape         = string
    node_shape_config = object({
      memory_in_gbs = number
      ocpus         = number
    })
    node_source_details = object({
      boot_volume_size_in_gbs = optional(number)
      image                   = string
    })
    node_config_details = object({
      nsgs = optional(list(string), [])
      placement_configs = list(object({
        availability_domain     = number
        capacity_reservation_id = optional(string)
        fault_domains           = optional(list(number), [])
        subnet                  = string
      }))
      size = number
      node_pool_pod_network_option_details = object({
        cni_type          = string
        max_pods_per_node = optional(number)
        pod_nsgs          = optional(list(string), [])
        pod_subnets       = optional(list(string), [])
      })
    })
    ssh_public_key = string
  }))
  default = {}
}

variable "oke_worker_node_image_ids" {
  description = "OKE worker image OCIDs keyed by the symbolic names used by node pools."
  type        = map(string)
  default     = {}
}

variable "addons" {
  description = "OKE managed add-ons keyed by a stable symbolic name."
  type = map(object({
    addon_name                       = string
    addon_version                    = optional(string)
    cluster                          = string
    compartment                      = optional(string)
    configurations                   = optional(map(string), {})
    load_balancer_subnet             = optional(string)
    override_existing                = optional(bool, false)
    remove_addon_resources_on_delete = optional(bool, false)
  }))
  default = {}
}
