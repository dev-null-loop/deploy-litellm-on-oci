variable "dns_zones" {
  description = "OCI DNS zones keyed by a stable symbolic name."
  type = map(object({
    compartment  = string
    dnssec_state = optional(string)
    name         = string
    scope        = optional(string, "GLOBAL")
    zone_type    = optional(string, "PRIMARY")
  }))
  default = {}
}

variable "dns_records" {
  description = "OCI DNS records whose targets resolve through registered runtime projections."
  type = map(object({
    domain = string
    rtype  = string
    target = string
    ttl    = number
    zone   = string
  }))
  default = {}
}

