variable "oci_secrets_provider_chart_version" {
  description = "Pinned OCI Secrets Store CSI provider Helm chart version."
  type        = string
}

variable "litellm" {
  description = "LiteLLM production deployment and its symbolic OCI resource references."
  type = object({
    certificate          = string
    cluster              = string
    compartment          = string
    dns_record           = string
    image                = string
    ingress_class        = string
    load_balancer_nsg    = string
    load_balancer_subnet = string
    name                 = string
    namespace            = string
    replicas             = number
    vault                = string
    waf_policy           = string
    autoscaling = object({
      cpu_target_percent = number
      max_replicas       = number
      min_replicas       = number
    })
    database = object({
      database        = string
      db_system       = string
      password_secret = string
      username        = string
    })
    generative_ai = object({
      fingerprint        = string
      model              = string
      model_alias        = string
      private_key_secret = string
      user_ocid          = string
    })
    load_balancer = object({
      maximum_bandwidth_mbps = number
      minimum_bandwidth_mbps = number
    })
    redis = object({
      cluster         = string
      password_secret = string
      username        = string
    })
    resources = object({
      limits = object({
        cpu    = string
        memory = string
      })
      requests = object({
        cpu    = string
        memory = string
      })
    })
    secrets = object({
      master_key = string
      salt_key   = string
    })
  })
}
