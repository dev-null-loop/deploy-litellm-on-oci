provider "oci" {
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
}

provider "kubernetes" {
  host                   = local.kubeconfig.clusters[0].cluster.server
  cluster_ca_certificate = base64decode(local.kubeconfig.clusters[0].cluster["certificate-authority-data"])

  exec {
    api_version = local.kube_user.exec.apiVersion
    args        = local.kube_user.exec.args
    command     = local.kube_user.exec.command
  }
}

provider "helm" {
  kubernetes = {
    host                   = local.kubeconfig.clusters[0].cluster.server
    cluster_ca_certificate = base64decode(local.kubeconfig.clusters[0].cluster["certificate-authority-data"])
    exec = {
      api_version = local.kube_user.exec.apiVersion
      args        = local.kube_user.exec.args
      command     = local.kube_user.exec.command
    }
  }
}

