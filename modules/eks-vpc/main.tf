data "aws_availability_zones" "available" {}

locals {
  azs              = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  public_subnets   = slice([for i in range(2, 16, 2) : cidrsubnet(var.eks_vpc_cidr, 8, i)], 0, var.az_count)
  private_subnets  = slice([for i in range(1, 16, 2) : cidrsubnet(var.eks_vpc_cidr, 8, i)], 0, var.az_count)
  database_subnets = slice([for i in range(1, 16, 2) : cidrsubnet(var.eks_vpc_cidr, 8, i)], var.az_count, 2 * var.az_count)
}

module "s3_bucket_flow_logs" {
  source                   = "terraform-aws-modules/s3-bucket/aws"
  bucket                   = "${var.cluster_name}-flow-logs"
  acl                      = "private"
  control_object_ownership = true
  object_ownership         = "ObjectWriter"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.12.1"

  name                         = var.cluster_name
  cidr                         = var.eks_vpc_cidr
  azs                          = local.azs
  public_subnets               = local.public_subnets
  private_subnets              = local.private_subnets
  database_subnets             = local.database_subnets
  create_database_subnet_group = true
  create_vpc                   = true
  enable_nat_gateway           = true
  enable_flow_log              = true
  flow_log_destination_type    = "s3"
  flow_log_destination_arn     = module.s3_bucket_flow_logs.s3_bucket_arn
  single_nat_gateway           = var.env != "production" ? true : false

  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    Accessibility                               = "public"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = 1
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "karpenter.sh/discovery"                    = var.cluster_name # TODO: to be determined during karpenter implementation
    Accessibility                               = "private"
  }
}