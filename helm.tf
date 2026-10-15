resource "helm_release" "oci_secrets_provider" {
  chart      = "oci-secrets-store-csi-driver-provider"
  name       = "oci-secrets-provider"
  namespace  = "kube-system"
  repository = "https://oracle.github.io/oci-secrets-store-csi-driver-provider/charts"
  version    = var.oci_secrets_provider_chart_version

  values = [yamlencode({
    "secrets-store-csi-driver" = {
      enableSecretRotation = true
      rotationPollInterval = "2m"
      syncSecret = {
        enabled = true
      }
    }
    provider = {
      oci = {
        auth = {
          types = {
            workload = {
              resourcePrincipalRegion  = var.region
              resourcePrincipalVersion = "3.0"
            }
          }
        }
      }
    }
  })]

  depends_on = [module.iam_policies, module.node_pools]
}

resource "helm_release" "litellm_secrets" {
  atomic           = true
  chart            = "${path.module}/charts/litellm-secrets"
  create_namespace = true
  name             = "${var.litellm.name}-secrets"
  namespace        = var.litellm.namespace
  timeout          = 900

  values = [yamlencode(local.litellm)]

  depends_on = [helm_release.oci_secrets_provider]
}

resource "helm_release" "litellm" {
  atomic           = true
  chart            = "${path.module}/charts/litellm"
  create_namespace = true
  name             = var.litellm.name
  namespace        = var.litellm.namespace
  timeout          = 1800

  values = [yamlencode(local.litellm)]

  depends_on = [
    helm_release.litellm_secrets,
    module.addons,
    module.db_systems,
    module.redis_cluster_user_attachments,
    module.redis_clusters,
  ]
}
