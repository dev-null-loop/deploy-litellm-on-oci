variable "vcns" {
  description = "VCNs keyed by a stable symbolic name."
  type = map(object({
    cidr_blocks  = list(string)
    compartment  = string
    display_name = string
    dns_label    = string
  }))
  default = {}
}

variable "internet_gateways" {
  description = "Internet gateways keyed by a stable symbolic name."
  type = map(object({
    compartment  = string
    display_name = string
    enabled      = optional(bool, true)
    vcn          = string
  }))
  default = {}
}

variable "nat_gateways" {
  description = "NAT gateways keyed by a stable symbolic name."
  type = map(object({
    compartment  = string
    display_name = string
    vcn          = string
  }))
  default = {}
}

variable "service_gateways" {
  description = "Service gateways keyed by a stable symbolic name."
  type = map(object({
    compartment  = string
    display_name = string
    service      = optional(string, "services")
    vcn          = string
  }))
  default = {}
}

variable "route_tables" {
  description = "Route tables with symbolic gateway and service references."
  type = map(object({
    compartment  = string
    display_name = string
    vcn          = string
    route_rules = list(object({
      description      = optional(string)
      destination      = string
      destination_type = string
      network_entity   = string
    }))
  }))
  default = {}
}

variable "security_lists" {
  description = "Security lists keyed by a stable symbolic name."
  type = map(object({
    compartment  = string
    display_name = string
    vcn          = string
    ingress_rules = optional(list(object({
      description = optional(string)
      protocol    = string
      source      = string
      source_type = optional(string)
      stateless   = optional(bool)
      tcp_options = optional(object({
        min = number
        max = number
      }))
    })), [])
    egress_rules = optional(list(object({
      description      = optional(string)
      destination      = string
      destination_type = optional(string)
      protocol         = string
      stateless        = optional(bool)
      tcp_options = optional(object({
        min = number
        max = number
      }))
    })), [])
  }))
  default = {}
}

variable "subnets" {
  description = "Regional subnets keyed by a stable symbolic name."
  type = map(object({
    cidr_block                 = string
    compartment                = string
    display_name               = string
    dns_label                  = string
    prohibit_internet_ingress  = optional(bool, true)
    prohibit_public_ip_on_vnic = optional(bool, true)
    route_table                = optional(string)
    security_lists             = optional(list(string), [])
    vcn                        = string
  }))
  default = {}
}

variable "nsgs" {
  description = "Network security groups keyed by a stable symbolic name."
  type = map(object({
    compartment  = string
    display_name = string
    vcn          = string
  }))
  default = {}
}

variable "nsg_rules" {
  description = "Network security group rules keyed by a stable symbolic name."
  type = map(object({
    nsg              = string
    description      = optional(string)
    direction        = string
    protocol         = string
    stateless        = optional(bool, false)
    source           = optional(string)
    source_type      = optional(string)
    destination      = optional(string)
    destination_type = optional(string)
    tcp_options = optional(object({
      destination_port_range = optional(object({
        max = number
        min = number
      }))
      source_port_range = optional(object({
        max = number
        min = number
      }))
    }))
    udp_options = optional(object({
      destination_port_range = optional(object({
        max = number
        min = number
      }))
      source_port_range = optional(object({
        max = number
        min = number
      }))
    }))
    icmp_options = optional(object({
      code = optional(number)
      type = number
    }))
  }))
  default = {}
}

