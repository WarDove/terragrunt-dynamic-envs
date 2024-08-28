module "ed_irsa_role" {
  count = var.enable_ed ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.44.0"

  role_name                  = "eks-ed-role"
  attach_external_dns_policy = true

  oidc_providers = {
    sts = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["external-dns:external-dns"]
    }
  }
}

resource "helm_release" "external_dns" {
  count      = var.enable_ed ? 1 : 0
  name       = "external-dns"
  namespace  = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = var.ed_version

  create_namespace = true

  set {
    name  = "txtOwnerId"
    value = "${var.cluster_name}-externaldns"
  }

  set {
    name  = "serviceAccount.name"
    value = "external-dns"
  }

  set {
    name  = "policy"
    value = "sync"
  }

  values = [
    yamlencode(
      {
        domainFilters = [local.domain_config.domain_name]
        "serviceAccount" = {
          "annotations" = {
            "eks.amazonaws.com/role-arn" = "arn:aws:iam::${var.account_id}:role/${module.ed_irsa_role[0].iam_role_name}"
          }
        }
      }
    )
  ]
}

