locals {
  availability_domains = {
    for idx, ad in data.oci_identity_availability_domains.ads.availability_domains : idx + 1 => ad.name
  }

  services = {
    for svc in data.oci_core_services.svcs.services :
    (startswith(lower(svc.cidr_block), "all-") ? "services" : "objectstorage") => {
      cidr_block = svc.cidr_block
      id         = svc.id
    }
  }

  network_entity_ids = merge(
    { for k, v in module.internet_gateways : "ig_${k}" => v.id },
    { for k, v in module.nat_gateways : "ng_${k}" => v.id },
    { for k, v in module.service_gateways : "sg_${k}" => v.id }
  )

  route_tables = {
    for k, v in var.route_tables : k => merge(v, {
      route_rules = [
        for rr in v.route_rules : {
          description       = rr.description
          destination       = try(local.services[rr.destination].cidr_block, rr.destination)
          destination_type  = rr.destination_type
          network_entity_id = local.network_entity_ids[rr.network_entity]
        }
      ]
    })
  }

  security_lists = {
    for k, v in var.security_lists : k => merge(v, {
      egress_rules = [
        for r in v.egress_rules : merge(r, {
          destination = try(local.services[r.destination].cidr_block, r.destination)
        })
      ]
    })
  }

  nsg_rules = {
    for k, v in var.nsg_rules : k => merge(v, {
      source = (
        v.source_type == "NETWORK_SECURITY_GROUP"
        ? module.nsgs[v.source].id
        : v.source
      )
      destination = (
        v.destination_type == "NETWORK_SECURITY_GROUP"
        ? module.nsgs[v.destination].id
        : try(local.services[v.destination].cidr_block, v.destination)
      )
    })
  }

  clusters = {
    for k, v in var.clusters : k => merge(v, {
      endpoint_config = merge(v.endpoint_config, {
        nsg_ids   = [for name in v.endpoint_config.nsgs : module.nsgs[name].id]
        subnet_id = module.subnets[v.endpoint_config.subnet].id
      })
      options = v.options == null ? null : merge(v.options, {
        service_lb_subnet_ids = [for name in v.options.service_lb_subnets : module.subnets[name].id]
      })
    })
  }

  node_pools = {
    for k, v in var.node_pools : k => merge(v, {
      image_id = var.oke_worker_node_image_ids[v.node_source_details.image]
      node_config_details = merge(v.node_config_details, {
        nsg_ids = [for name in v.node_config_details.nsgs : module.nsgs[name].id]
        placement_configs = [
          for pc in v.node_config_details.placement_configs : {
            availability_domain     = local.availability_domains[pc.availability_domain]
            capacity_reservation_id = pc.capacity_reservation_id
            fault_domains           = [for fd in pc.fault_domains : "FAULT-DOMAIN-${fd}"]
            subnet_id               = module.subnets[pc.subnet].id
          }
        ]
        node_pool_pod_network_option_details = merge(v.node_config_details.node_pool_pod_network_option_details, {
          pod_nsg_ids    = [for name in v.node_config_details.node_pool_pod_network_option_details.pod_nsgs : module.nsgs[name].id]
          pod_subnet_ids = [for name in v.node_config_details.node_pool_pod_network_option_details.pod_subnets : module.subnets[name].id]
        })
      })
      node_source_details = {
        boot_volume_size_in_gbs = v.node_source_details.boot_volume_size_in_gbs
        source_type             = "image"
      }
    })
  }

  addons = {
    for k, v in var.addons : k => merge(v, {
      configurations = [
        for k, v in merge(
          v.configurations,
          v.addon_name == "NativeIngressController" ? {
            authType             = "workloadIdentity"
            compartmentId        = var.compartment_ids[v.compartment]
            loadBalancerSubnetId = module.subnets[v.load_balancer_subnet].id
          } : {}
          ) : {
          key   = k
          value = v
        }
      ]
    })
  }

  iam_policies = {
    for k, v in var.iam_policies : k => merge(v, {
      statements = concat(
        v.statements,
        [
          for s in v.group_statements : "Allow group ${s.group} to ${s.verb} ${s.resource} in compartment id ${var.compartment_ids[s.resource_compartment]}"
        ],
        [
          for s in v.workload_identity_statements : "Allow any-user to ${s.verb} ${s.resource} in compartment id ${var.compartment_ids[s.resource_compartment]} where all {request.principal.type = 'workload', request.principal.namespace = '${s.namespace}', request.principal.service_account = '${s.service_account}', request.principal.cluster_id = '${module.clusters[s.cluster].id}'}"
        ]
      )
    })
  }

  kubeconfig = yamldecode(data.oci_containerengine_cluster_kube_config.litellm.content)
  kube_user  = local.kubeconfig.users[0].user

  db_systems = {
    for k, v in var.db_systems : k => merge(v, {
      credentials = {
        username = v.credentials.username
        password_details = {
          password_type  = "VAULT_SECRET"
          secret_id      = module.secrets[v.credentials.secret].id
          secret_version = tostring(module.secrets[v.credentials.secret].current_version_number)
        }
      }
      network_details = merge(v.network_details, {
        nsg_ids   = [for name in v.network_details.nsgs : module.nsgs[name].id]
        subnet_id = module.subnets[v.network_details.subnet].id
      })
      storage_details = merge(v.storage_details, {
        availability_domain = v.storage_details.availability_domain == null ? null : local.availability_domains[v.storage_details.availability_domain]
      })
    })
  }

  dns_record_targets = {
    litellm_ingress = data.kubernetes_ingress_v1.litellm.status[0].load_balancer[0].ingress[0].ip
  }

  dns_records = {
    for k, v in var.dns_records : k => merge(v, {
      items = [{
        domain = v.domain
        rdata  = local.dns_record_targets[v.target]
        rtype  = v.rtype
        ttl    = v.ttl
      }]
    })
  }

  redis_cluster_user_attachments = {
    for k, v in var.redis_cluster_user_attachments : k => {
      oci_cache_users  = [for name in v.redis_users : module.redis_users[name].id]
      redis_cluster_id = module.redis_clusters[v.redis_cluster].id
    }
  }

  litellm = {
    certificateId              = module.certificates[var.litellm.certificate].id
    compartmentId              = var.compartment_ids[var.litellm.compartment]
    databaseHost               = module.db_systems[var.litellm.database.db_system].network_details[0].primary_db_endpoint_private_ip
    databaseName               = var.litellm.database.database
    databasePasswordSecretName = var.secrets[var.litellm.database.password_secret].secret_name
    databaseUsername           = var.litellm.database.username
    hostname                   = var.dns_records[var.litellm.dns_record].domain
    image                      = var.litellm.image
    ingressClass               = var.litellm.ingress_class
    loadBalancerMaximumMbps    = var.litellm.load_balancer.maximum_bandwidth_mbps
    loadBalancerMinimumMbps    = var.litellm.load_balancer.minimum_bandwidth_mbps
    loadBalancerNsgId          = module.nsgs[var.litellm.load_balancer_nsg].id
    loadBalancerSubnetId       = module.subnets[var.litellm.load_balancer_subnet].id
    masterKeySecretName        = var.secrets[var.litellm.secrets.master_key].secret_name
    model                      = var.litellm.generative_ai.model
    modelAlias                 = var.litellm.generative_ai.model_alias
    name                       = var.litellm.name
    namespace                  = var.litellm.namespace
    ociCompartmentId           = var.compartment_ids[var.litellm.compartment]
    ociFingerprint             = var.litellm.generative_ai.fingerprint
    ociPrivateKeySecretName    = var.secrets[var.litellm.generative_ai.private_key_secret].secret_name
    ociRegion                  = var.region
    ociTenancyId               = var.tenancy_ocid
    ociUserId                  = var.litellm.generative_ai.user_ocid
    redisHost                  = module.redis_clusters[var.litellm.redis.cluster].primary_fqdn
    redisPasswordSecretName    = var.secrets[var.litellm.redis.password_secret].secret_name
    redisUsername              = var.litellm.redis.username
    replicas                   = var.litellm.replicas
    resources                  = var.litellm.resources
    saltKeySecretName          = var.secrets[var.litellm.secrets.salt_key].secret_name
    vaultId                    = module.vaults[var.litellm.vault].id
    wafPolicyId                = module.waf_policies[var.litellm.waf_policy].id
    autoscaling                = var.litellm.autoscaling
  }
}
