include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "tfr://registry.terraform.io/terraform-aws-modules/vpc/aws?version=5.12.1"
}

locals {
  common_vars      = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  name             = "${local.common_vars.inputs.company_prefix}-vpc"
  vpc_cidr         = "10.2.0.0/16"
  azs              = ["us-west-2a", "us-west-2b"]
  public_subnets   = slice([for i in range(2, 16, 2) : cidrsubnet(local.vpc_cidr, 8, i)], 0, 3)
  private_subnets  = slice([for i in range(1, 16, 2) : cidrsubnet(local.vpc_cidr, 8, i)], 0, 3)
  database_subnets = slice([for i in range(1, 16, 2) : cidrsubnet(local.vpc_cidr, 8, i)], 3, 5)
}

inputs = {
  name                         = local.name
  cidr                         = local.vpc_cidr
  azs                          = local.azs
  public_subnets               = local.public_subnets
  private_subnets              = local.private_subnets
  database_subnets             = local.database_subnets
  create_database_subnet_group = true
  create_vpc                   = true
  enable_nat_gateway           = true
  single_nat_gateway           = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"              = 1
    "kubernetes.io/cluster/${local.name}" = "owned"
    "karpenter.sh/discovery"              = local.name
    Accessibility                         = "public"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"     = 1
    "kubernetes.io/cluster/${local.name}" = "owned"
    "karpenter.sh/discovery"              = local.name
    Accessibility                         = "private"
  }
}
