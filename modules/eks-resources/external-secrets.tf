module "es_irsa_role" {
  count = var.enable_es ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.44.0"

  role_name                      = "eks-es-role"
  attach_external_secrets_policy = true

  oidc_providers = {
    sts = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["external-secrets:external-secrets"]
    }
  }
}

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
            "eks.amazonaws.com/role-arn" = "arn:aws:iam::${var.account_id}:role/${module.es_irsa_role[0].iam_role_name}"
          }
        }
      }
    )
  ]
}