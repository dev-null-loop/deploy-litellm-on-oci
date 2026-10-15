variable "vaults" {
  description = "OCI Vaults keyed by a stable symbolic name."
  type = map(object({
    compartment  = string
    display_name = string
    vault_type   = string
  }))
  default = {}
}

variable "keys" {
  description = "OCI Vault keys keyed by a stable symbolic name."
  type = map(object({
    compartment              = string
    display_name             = string
    is_auto_rotation_enabled = optional(bool)
    key_shape = object({
      algorithm = string
      curve_id  = optional(string)
      length    = number
    })
    protection_mode = optional(string)
    vault           = string
  }))
  default = {}
}

variable "secrets" {
  description = "OCI Vault secrets keyed by a stable symbolic name."
  type = map(object({
    compartment            = string
    description            = optional(string)
    enable_auto_generation = optional(bool, false)
    key                    = string
    secret_name            = string
    vault                  = string
    secret_content = optional(object({
      content_type = string
      content      = optional(string)
      name         = optional(string)
      stage        = optional(string)
    }))
    secret_generation_context = optional(object({
      generation_template = string
      generation_type     = string
      passphrase_length   = optional(number)
      secret_template     = optional(string)
    }))
  }))
  default = {}
}

