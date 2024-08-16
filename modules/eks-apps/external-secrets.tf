resource "helm_release" "external_secrets" {
  count      = var.enable_es ? 1 : 0
  name       = "external-secrets"
  namespace  = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = var.es_version

  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "webhook.port"
    value = "9443"
  }
}

resource "kubernetes_service_account" "cluster_secret_store" {
  count = var.enable_es ? 1 : 0

  metadata {
    name      = "cluster-secret-store"
    namespace = helm_release.external_secrets[0].namespace
  }
}