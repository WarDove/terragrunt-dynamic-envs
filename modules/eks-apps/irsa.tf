variable "deployments" {
  type = set(string)
}
variable "cluster_name" {}
variable "oidc_provider_arn" {}
variable "kubeconfig_profile" {}
variable "namespace" {}
variable "cluster_certificate_authority_data" {}
variable "cluster_endpoint" {}

variable "dynamic_env" {
  type    = bool
  default = false
}

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

module "deployment_irsa_role" {
  for_each = var.deployments
  source   = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version  = "~> 5.44.0"

  role_name        = "${each.key}-irsa-role-${var.namespace}"
  role_policy_arns = {}

  oidc_providers = {
    sts = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.namespace}:${each.key}"]
    }
  }
}

resource "kubernetes_service_account" "deployment_service_account" {
  for_each = var.deployments
  metadata {
    name      = each.key
    namespace = kubernetes_namespace.deployment_namespace.metadata[0].name
    labels    = { "app.kubernetes.io/name" : each.key }

    annotations = {
      "eks.amazonaws.com/role-arn" = module.deployment_irsa_role[each.key].iam_role_arn
    }
  }
}


