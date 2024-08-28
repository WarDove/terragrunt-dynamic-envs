resource "kubernetes_namespace" "deployment_namespace" {
  metadata {
    name = var.namespace
    labels = {
      reloader = "enabled"
    }
    annotations = {
      name    = var.namespace
      dynamic = var.dynamic_env
    }
  }
}