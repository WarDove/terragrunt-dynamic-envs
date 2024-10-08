include "root" {
  path = find_in_parent_folders()
}

dependency "eks-vpc" {
  config_path                             = "../eks-vpc"
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs = {
    vpc_id     = "fake-vpc-id"
    subnet_ids = ["fake-subnet-id1", "fake-subnet-id2"]
  }
}

inputs = {
  cluster_version = "1.30"
  subnet_ids      = dependency.eks-vpc.outputs.private_subnets
  vpc_id          = dependency.eks-vpc.outputs.vpc_id
}