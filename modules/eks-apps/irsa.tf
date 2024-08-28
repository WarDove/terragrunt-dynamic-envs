module "deployment_irsa_role" {
  for_each = var.deployments
  source   = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version  = "~> 5.44.0"

  role_name        = "${each.value}-irsa-role-${var.namespace}"
  role_policy_arns = {}

  oidc_providers = {
    sts = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.namespace}:${each.value}"]
    }
  }
}

resource "kubernetes_service_account" "deployment_service_account" {
  for_each = var.deployments
  metadata {
    name      = each.value
    namespace = kubernetes_namespace.deployment_namespace.metadata[0].name
    labels    = { "app.kubernetes.io/name" : each.value }

    annotations = {
      "eks.amazonaws.com/role-arn" = module.deployment_irsa_role[each.value].iam_role_arn
    }
  }
}