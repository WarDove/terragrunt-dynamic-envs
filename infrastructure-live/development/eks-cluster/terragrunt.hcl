include "root" {
  path = find_in_parent_folders()
}

dependency "eks-network" {
  config_path = "../eks-network"
}

terraform {
  source = "tfr://registry.terraform.io/terraform-aws-modules/eks/aws?version=20.23.0"
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
}

inputs = {
  cluster_version               = "1.30"
  cluster_name                  = local.common_vars.inputs.company_prefix
  subnet_ids                    = dependency.eks-network.outputs.subnets["private"][*].id
  bootstrap_self_managed_addons = true
}

