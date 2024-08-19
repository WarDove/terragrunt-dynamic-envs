locals {
  domain_config = var.domain_config[var.env]
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
            "eks.amazonaws.com/role-arn" = "arn:aws:iam::${var.account_id}:role/${var.ed_role_name}"
          }
        }
    })
  ]
}

