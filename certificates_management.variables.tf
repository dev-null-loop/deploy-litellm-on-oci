variable "certificates" {
  description = "Certificates stored and managed by OCI Certificates."
  type = map(object({
    compartment = string
    description = optional(string)
    name        = string
    certificate_config = object({
      cert_chain_pem                  = optional(string)
      certificate_pem                 = optional(string)
      certificate_profile_type        = optional(string)
      config_type                     = string
      csr_pem                         = optional(string)
      issuer_certificate_authority_id = optional(string)
      key_algorithm                   = optional(string)
      private_key_pem                 = optional(string)
      private_key_pem_passphrase      = optional(string)
      signature_algorithm             = optional(string)
      stage                           = optional(string)
      subject = optional(object({
        common_name            = string
        country                = optional(string)
        locality_name          = optional(string)
        organization           = optional(string)
        organizational_unit    = optional(string)
        state_or_province_name = optional(string)
      }))
      subject_alternative_names = optional(list(object({
        type  = string
        value = string
      })), [])
      validity = optional(object({
        time_of_validity_not_after  = string
        time_of_validity_not_before = optional(string)
      }))
      version_name = optional(string)
    })
    certificate_rules = optional(list(object({
      advance_renewal_period = string
      renewal_interval       = string
      rule_type              = string
    })), [])
  }))
  default = {}
}

