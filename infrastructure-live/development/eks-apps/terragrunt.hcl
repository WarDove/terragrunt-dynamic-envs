include "root" {
  path = find_in_parent_folders()
}

dependency "eks-cluster" {
  config_path = "../eks-cluster"
}

terraform {
  source = "${get_repo_root()}/modules/eks-apps"
}

inputs = {
  karpenter_version                  = "0.37.0"
  enable_karpenter                   = dependency.eks-cluster.outputs.enable_karpenter
  node_iam_role_arn                  = dependency.eks-cluster.outputs.node_iam_role_arn
  karpenter_role_arn                 = dependency.eks-cluster.outputs.karpenter_role_arn
  karpenter_termination_queue_name   = dependency.eks-cluster.outputs.karpenter_termination_queue_name
  cluster_endpoint                   = dependency.eks-cluster.outputs.cluster_endpoint
  cluster_certificate_authority_data = dependency.eks-cluster.outputs.cluster_certificate_authority_data
}

generate "provider_kubernetes" {
  path      = "provider-kubernetes.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--profile", var.kubeconfig_profile]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--profile", var.kubeconfig_profile]
      command     = "aws"
    }
  }
}
EOF
}

# generate "provider_helm" {
#   path      = "provider-helm.tf"
#   if_exists = "overwrite"
#   contents  = <<EOF

# }
# EOF
# }

/*
Alternative kubernvrg  auth method

data "aws_eks_cluster_auth" "eks" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

*/