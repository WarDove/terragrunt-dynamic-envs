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

  values = [
    yamlencode(
      {
        "serviceAccount" = {
          "annotations" = {
            "eks.amazonaws.com/role-arn" = "arn:aws:iam::${var.account_id}:role/${var.albc_role_name}"
          }
        }
    })
  ]
}

# TODO: these below have to be created on application module instead so remove inputs and adjust hcl files accordingly
# data "aws_security_group" "albc_backend_sg" {
#   depends_on = [helm_release.albc]
#   filter {
#     name   = "tag:elbv2.k8s.aws/resource"
#     values = ["backend-sg"]
#   }
# }
#
# resource "aws_security_group" "test_pod_sg" {
#   name   = "test-pod-sg"
#   vpc_id = var.eks_vpc_id
#   ingress {
#     from_port       = 80
#     to_port         = 80
#     protocol        = "tcp"
#     security_groups = [data.aws_security_group.albc_backend_sg.id]
#   }
# }
#
#
# resource "kubernetes_manifest" "test_sa_sgp" {
#   manifest = {
#     "apiVersion" = "vpcresources.k8s.aws/v1beta1"
#     "kind"       = "SecurityGroupPolicy"
#     "metadata" = {
#       "name"      = "test-sgp"
#       "namespace" = "default"
#     }
#
#     "spec" = {
#       "serviceAccountSelector" = {
#         "matchLabels" = {
#           "app" = "test"
#         }
#       }
#
#       "securityGroups" = {
#         "groupIds" = [
#           var.eks_sg_id,
#           aws_security_group.test_pod_sg.id
#         ]
#       }
#     }
#   }
# }