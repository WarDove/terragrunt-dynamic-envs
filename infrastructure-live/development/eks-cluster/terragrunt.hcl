include "root" {
  path = find_in_parent_folders()
}

dependency "eks-vpc" {
  config_path = "../eks-vpc"
}

terraform {
  source = "${get_repo_root()}/modules/eks-vpc"
}

inputs = {
  cw_logs_enabled = false
  subnet_ids      = dependency.eks-vpc.outputs.private_subnets
}