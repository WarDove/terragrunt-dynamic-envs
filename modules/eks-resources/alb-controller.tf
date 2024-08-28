module "albc_irsa_role" {
  count = var.enable_albc ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.44.0"

  role_name                              = "eks-albc-role"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    sts = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_security_group" "albc_backend_sg" {
  count       = var.enable_albc ? 1 : 0
  name        = "albc-backend-sg"
  description = "Security group for the ALBC backend, to provide access to individual exposed pods"
  vpc_id      = var.vpc_id

  tags = {
    "elbv2.k8s.aws/resource" = "backend-sg"
  }
}

resource "helm_release" "albc" {
  count        = var.enable_albc ? 1 : 0
  name         = "aws-lbc"
  repository   = "https://aws.github.io/eks-charts"
  chart        = "aws-load-balancer-controller"
  version      = var.albc_version
  namespace    = "kube-system"
  force_update = true

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "vpcId"
    value = var.eks_vpc_id
  }

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "clusterSecretsPermissions.allowAllSecrets"
    value = true
  }

  set {
    name  = "replicaCount"
    value = 1
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "backendSecurityGroup"
    value = var.albc_backend_sg_id
  }

  values = [
    yamlencode(
      {
        "serviceAccount" = {
          "annotations" = {
            "eks.amazonaws.com/role-arn" = "arn:aws:iam::${var.account_id}:role/${module.albc_irsa_role[0].iam_role_name}"
          }
        }
      }
    )
  ]
}