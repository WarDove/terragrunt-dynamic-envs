module "application_irsa_role" {
  for_each = var.app_statements
  source   = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version  = "~> 5.44.0"

  role_name        = "${each.key}-irsa-role-${var.namespace}"
  role_policy_arns = aws_iam_policy.application_policy[each.key][*].arn

  oidc_providers = {
    sts = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.namespace}:${each.value}"]
    }
  }
}

resource "kubernetes_service_account" "deployment_service_account" {
  for_each = var.app_statements
  metadata {
    name      = each.key
    namespace = var.namespace
    labels    = { "app.kubernetes.io/name" : each.key }

    annotations = {
      "eks.amazonaws.com/role-arn" = module.application_irsa_role[each.key].iam_role_arn
    }
  }
}