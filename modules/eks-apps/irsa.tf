data "aws_iam_policy_document" "application_policy" {
  for_each = { for v in local.eks_app_statements : v.name => v }

  dynamic "statement" {
    for_each = each.value.statements

    content {
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources
    }
  }
}

resource "kubernetes_service_account" "deployment_service_account" {
  for_each = module.application_irsa_role
  metadata {
    name      = each.key
    namespace = var.namespace
    labels    = { "app.kubernetes.io/name" : each.key }

    annotations = {
      "eks.amazonaws.com/role-arn" = each.value.iam_role_arn
    }
  }
}

resource "aws_iam_policy" "application_policy" {
  for_each    = data.aws_iam_policy_document.application_policy
  name        = "${each.key}-irsa-policy-${var.namespace}"
  description = "${title(each.key)} IAM policy for dedicated IRSA"
  policy      = each.value.json
}

module "application_irsa_role" {
  for_each = aws_iam_policy.application_policy
  source   = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version  = "~> 5.44.0"

  role_name        = "${each.key}-irsa-role-${var.namespace}"
  role_policy_arns = each.value[*].arn

  oidc_providers = {
    sts = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.namespace}:${each.key}"]
    }
  }
}