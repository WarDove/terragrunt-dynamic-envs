resource "helm_release" "external_secrets" {
  count      = var.enable_es ? 1 : 0
  name       = "external-secrets"
  namespace  = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = var.es_version
  wait       = true
  timeout    = 600

  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "webhook.port"
    value = "9443"
  }

  values = [
    yamlencode(
      {
        "serviceAccount" = {
          "annotations" = {
            "eks.amazonaws.com/role-arn" = "arn:aws:iam::${var.account_id}:role/${var.es_role_name}"
          }
        }
      }
    )
  ]
}