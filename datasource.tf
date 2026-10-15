data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_services" "svcs" {}

data "oci_containerengine_cluster_kube_config" "litellm" {
  cluster_id = module.clusters[var.litellm.cluster].id
}

data "kubernetes_ingress_v1" "litellm" {
  metadata {
    name      = var.litellm.name
    namespace = var.litellm.namespace
  }

  depends_on = [helm_release.litellm]
}

