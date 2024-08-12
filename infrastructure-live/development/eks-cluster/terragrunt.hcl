include "root" {
  path = find_in_parent_folders()
}

dependency "eks-network" {
  config_path = "../eks-network"
}

terraform {
  source = "tfr://registry.terraform.io/terraform-aws-modules/eks/aws?version=20.23.0"
}

inputs = {}

