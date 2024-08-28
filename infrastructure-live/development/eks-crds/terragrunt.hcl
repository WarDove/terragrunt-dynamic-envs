include "root" {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../eks-resources"]
}

dependency "eks-cluster" {
  config_path                             = "../eks-cluster"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    enable_karpenter                   = false
    enable_es                          = false
    node_instance_profile_name         = "fake-instance-profile"
    cluster_endpoint                   = "https://fake.cluster.endpoint"
    cluster_certificate_authority_data = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUJJakFOQmd"
  }
}

inputs = {
  enable_arc                         = true
  arc_version                        = "0.9.3"
  enable_karpenter                   = dependency.eks-resources.outputs.enable_karpenter
  enable_es                          = dependency.eks-resources.outputs.enable_es
  node_instance_profile_name         = dependency.eks-resources.outputs.node_instance_profile_name
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