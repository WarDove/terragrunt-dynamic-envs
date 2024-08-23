include "root" {
  path = find_in_parent_folders()
}

dependency "eks-cluster" {
  config_path                             = "../eks-cluster"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    enable_karpenter                   = false
    enable_albc                        = false
    enable_es                          = false
    enable_ed                          = false
    eks_vpc_id                         = "fake-vpc-id"
    eks_sg_id                          = "fake-sg-id"
    albc_backend_sg_id                 = "fake-sg-id"
    acm_certificate_arn                = "fake-acm-cert-arn"
    karpenter_role_arn                 = "fake-role-arn"
    oidc_provider_arn                  = "fake-oidc-provider-arn"
    karpenter_termination_queue_name   = "fake-queue-name"
    cluster_endpoint                   = "https://fake.cluster.endpoint"
    cluster_certificate_authority_data = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUJJakFOQmdrcWhraUc5dzBCQVFFRkFBT0NBUThBTUlJQkNnS0NBUUVBN1FJREFRQUJNQTBHQ1NxR1NJYjMKRFFFQkN3VUFBNElCQVFBeEFsWUNMeFk9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
  }
}

inputs = {
  karpenter_version                  = "0.37.0"
  albc_version                       = "1.8.2"
  es_version                         = "0.10.0"
  ed_version                         = "1.14.5"
  argocd_version                     = "7.4.4"
  reloader_version                   = "1.0.121"
  enable_argocd                      = true
  enable_reloader                    = true
  enable_karpenter                   = dependency.eks-cluster.outputs.enable_karpenter
  enable_albc                        = dependency.eks-cluster.outputs.enable_albc
  enable_es                          = dependency.eks-cluster.outputs.enable_es
  enable_ed                          = dependency.eks-cluster.outputs.enable_ed
  eks_vpc_id                         = dependency.eks-cluster.outputs.eks_vpc_id
  eks_sg_id                          = dependency.eks-cluster.outputs.eks_sg_id
  albc_backend_sg_id                 = dependency.eks-cluster.outputs.albc_backend_sg_id
  acm_certificate_arn                = dependency.eks-cluster.outputs.acm_certificate_arn
  node_instance_profile_name         = dependency.eks-cluster.outputs.node_instance_profile_name
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


/*

Alternative kubernetes  auth method

data "aws_eks_cluster_auth" "eks" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

*/