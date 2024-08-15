include "root" {
  path = find_in_parent_folders()
}

dependency "eks-vpc" {
  config_path = "../eks-vpc"
}

terraform {
  source = "${get_repo_root()}/modules/${basename(get_terragrunt_dir())}"
}

inputs = {
  cluster_version  = "1.30"
  enable_karpenter = true
  subnet_ids       = dependency.eks-vpc.outputs.private_subnets
  vpc_id           = dependency.eks-vpc.outputs.vpc_id
}