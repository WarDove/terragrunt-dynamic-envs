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
  cluster_version = "1.30"
  subnet_ids      = dependency.eks-vpc.outputs.private_subnets
  cw_logs_enabled = false
}

generate "provider_kubernetes" {
  path      = "provider-kubernetes.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "kubernetes" {
  host                   = dependency.eks-cluster.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(dependency.eks-cluster.outputs.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name, "--profile", var.profile]
    command     = "aws"
  }
}
EOF
}

# generate "provider_helm" {
#   path      = "provider-helm.tf"
#   if_exists = "overwrite"
#   contents  = <<EOF
# provider "helm" {
#   kubernetes {
#     host                   = dependency.eks-cluster.outputs.cluster_endpoint
#     token                  = dependency.eks-cluster.outputs.kube_api_token
#     cluster_ca_certificate = base64decode(dependency.eks-cluster.outputs.kubeconfig_certificate_authority_data)
#   }
# }
# EOF
# }
