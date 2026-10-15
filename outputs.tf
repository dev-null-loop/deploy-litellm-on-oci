output "vcns" {
  description = "VCN identifiers and CIDR blocks keyed by symbolic name."
  value = {
    for k, v in module.vcns : k => {
      cidr_blocks = v.cidr_blocks
      id          = v.id
      state       = v.state
    }
  }
}

output "subnets" {
  description = "Subnet identifiers and CIDR blocks keyed by symbolic name."
  value = {
    for k, v in module.subnets : k => {
      cidr_block = v.cidr_block
      id         = v.id
      state      = v.state
    }
  }
}

output "gateways" {
  description = "Core gateway identifiers and operator-facing state."
  value = {
    internet = {
      for k, v in module.internet_gateways : k => {
        id    = v.id
        state = v.state
      }
    }
    nat = {
      for k, v in module.nat_gateways : k => {
        id     = v.id
        nat_ip = v.nat_ip
        state  = v.state
      }
    }
    service = {
      for k, v in module.service_gateways : k => {
        id    = v.id
        state = v.state
      }
    }
  }
}

output "route_tables" {
  description = "Route-table identifiers and state keyed by symbolic name."
  value = {
    for k, v in module.route_tables : k => {
      id    = v.id
      state = v.state
    }
  }
}

output "security_lists" {
  description = "Security-list identifiers keyed by symbolic name."
  value = {
    for k, v in module.security_lists : k => {
      id = v.id
    }
  }
}

output "nsgs" {
  description = "Network security group identifiers and state keyed by symbolic name."
  value = {
    for k, v in module.nsgs : k => {
      id    = v.id
      state = v.state
    }
  }
}

output "clusters" {
  description = "OKE identifiers and endpoints keyed by symbolic name."
  value = {
    for k, v in module.clusters : k => {
      id                  = v.id
      kubernetes_endpoint = v.kubernetes_endpoint
      name                = v.name
      state               = v.state
    }
  }
}

output "node_pools" {
  description = "OKE node-pool identifiers keyed by symbolic name."
  value = {
    for k, v in module.node_pools : k => {
      id = v.id
    }
  }
}

output "addons" {
  description = "OKE add-on versions and state keyed by symbolic name."
  value = {
    for k, v in module.addons : k => {
      current_installed_version = v.current_installed_version
      id                        = v.id
      state                     = v.state
    }
  }
}

output "db_systems" {
  description = "PostgreSQL identifiers, private endpoints, and state keyed by symbolic name."
  value = {
    for k, v in module.db_systems : k => {
      id                             = v.id
      primary_db_endpoint_private_ip = v.network_details[0].primary_db_endpoint_private_ip
      state                          = v.state
    }
  }
}

output "redis_clusters" {
  description = "Redis identifiers, private hostnames, and state keyed by symbolic name."
  value = {
    for k, v in module.redis_clusters : k => {
      id           = v.id
      primary_fqdn = v.primary_fqdn
      state        = v.state
    }
  }
}

output "redis_users" {
  description = "OCI Cache user identifiers and state keyed by symbolic name."
  value = {
    for k, v in module.redis_users : k => {
      id    = v.id
      state = v.state
    }
  }
}

output "vaults" {
  description = "Vault identifiers and state keyed by symbolic name."
  value = {
    for k, v in module.vaults : k => {
      id    = v.id
      state = v.state
    }
  }
}

output "keys" {
  description = "Vault key identifiers and state keyed by symbolic name."
  value = {
    for k, v in module.keys : k => {
      id    = v.id
      state = v.state
    }
  }
}

output "secrets" {
  description = "Vault secret identifiers and state keyed by symbolic name."
  value = {
    for k, v in module.secrets : k => {
      id    = v.id
      state = v.state
    }
  }
}

output "iam_policies" {
  description = "IAM policy identifiers keyed by symbolic name."
  value = {
    for k, v in module.iam_policies : k => {
      id = v.id
    }
  }
}

output "certificates" {
  description = "Certificate identifiers and state keyed by symbolic name."
  value = {
    for k, v in module.certificates : k => {
      id    = v.id
      state = v.state
    }
  }
}

output "waf_policies" {
  description = "WAF policy identifiers and state keyed by symbolic name."
  value = {
    for k, v in module.waf_policies : k => {
      id    = v.id
      state = v.state
    }
  }
}

output "dns_zones" {
  description = "DNS zone identifiers and authoritative nameservers keyed by symbolic name."
  value = {
    for k, v in module.dns_zones : k => {
      id          = v.id
      nameservers = v.nameservers
      state       = v.state
    }
  }
}

output "dns_records" {
  description = "DNS record items and owning zone identifiers keyed by symbolic name."
  value = {
    for k, v in module.dns_records : k => {
      items           = v.items
      zone_name_or_id = module.dns_zones[var.dns_records[k].zone].id
    }
  }
}

output "litellm" {
  description = "Human-usable LiteLLM endpoint and load balancer address."
  value = {
    endpoint         = "https://${var.dns_records[var.litellm.dns_record].domain}"
    load_balancer_ip = data.kubernetes_ingress_v1.litellm.status[0].load_balancer[0].ingress[0].ip
  }
}
