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
            "eks.amazonaws.com/role-arn" = "arn:aws:iam::${var.account_id}:role/${var.albc_role_name}"
          }
        }
      }
    )
  ]
}