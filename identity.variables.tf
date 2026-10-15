variable "tenancy_ocid" {
  description = "OCI tenancy OCID."
  type        = string
}

variable "user_ocid" {
  description = "OCI user OCID used by Terraform."
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint of the Terraform user's API signing key."
  type        = string
}

variable "private_key_path" {
  description = "Filesystem path to the Terraform user's API signing private key."
  type        = string
}

variable "region" {
  description = "OCI region in which to deploy the stack."
  type        = string
}

variable "compartment_ids" {
  description = "Compartment OCIDs keyed by the symbolic names used in resource collections."
  type        = map(string)
}

variable "iam_policies" {
  description = "OCI Identity policies keyed by a stable symbolic name."
  type = map(object({
    compartment = string
    description = string
    name        = string
    statements  = optional(list(string), [])
    group_statements = optional(list(object({
      group                = string
      resource             = string
      resource_compartment = string
      verb                 = string
    })), [])
    workload_identity_statements = optional(list(object({
      cluster              = string
      namespace            = string
      resource             = string
      resource_compartment = string
      service_account      = string
      verb                 = string
    })), [])
  }))
  default = {}
}
