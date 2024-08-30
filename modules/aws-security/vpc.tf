data "aws_availability_zones" "available" {}

locals {
  azs              = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  public_subnets   = slice([for i in range(2, 16, 2) : cidrsubnet(var.vpc_cidr, 8, i)], 0, var.az_count)
  private_subnets  = slice([for i in range(1, 16, 2) : cidrsubnet(var.vpc_cidr, 8, i)], 0, var.az_count)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.12.1"

  name                         = "${var.company_prefix}-${var.env}"
  cidr                         = var.vpc_cidr
  azs                          = local.azs
  public_subnets               = local.public_subnets
  private_subnets              = local.private_subnets
  create_vpc                   = true
  enable_nat_gateway           = true
  single_nat_gateway           = true
}