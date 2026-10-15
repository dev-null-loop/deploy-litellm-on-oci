variable "redis_clusters" {
  description = "OCI Cache with Redis clusters keyed by a stable symbolic name."
  type = map(object({
    cluster_mode       = optional(string)
    compartment        = string
    display_name       = string
    node_count         = number
    node_memory_in_gbs = number
    nsgs               = optional(list(string), [])
    shard_count        = optional(number)
    software_version   = string
    subnet             = string
  }))
  default = {}
}

variable "redis_users" {
  description = "OCI Cache users keyed by a stable symbolic name."
  type = map(object({
    acl_string  = string
    compartment = string
    authentication_mode = object({
      authentication_type = string
      hashed_passwords    = optional(list(string))
    })
    description = string
    name        = string
    status      = optional(string)
  }))
  default = {}
}

variable "redis_cluster_user_attachments" {
  description = "OCI Cache user attachments keyed by a stable symbolic name."
  type = map(object({
    redis_cluster = string
    redis_users   = list(string)
  }))
  default = {}
}
