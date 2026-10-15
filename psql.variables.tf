variable "db_systems" {
  description = "OCI Database with PostgreSQL systems keyed by a stable symbolic name."
  type = map(object({
    compartment                 = string
    db_version                  = string
    display_name                = string
    instance_count              = optional(number)
    instance_memory_size_in_gbs = optional(number)
    instance_ocpu_count         = optional(number)
    shape                       = string
    credentials = object({
      secret   = string
      username = string
    })
    management_policy = optional(object({
      backup_policy = optional(object({
        backup_start      = optional(string)
        days_of_the_month = optional(list(number))
        days_of_the_week  = optional(list(string))
        kind              = optional(string)
        retention_days    = optional(number)
      }))
      maintenance_window_start = optional(string)
    }))
    network_details = object({
      is_reader_endpoint_enabled     = optional(bool)
      nsgs                           = optional(list(string), [])
      primary_db_endpoint_private_ip = optional(string)
      subnet                         = string
    })
    storage_details = object({
      availability_domain   = optional(number)
      iops                  = optional(string)
      is_regionally_durable = bool
      system_type           = string
    })
  }))
  default = {}
}

