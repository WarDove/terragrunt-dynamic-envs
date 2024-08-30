# https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/create-a-report-of-network-access-analyzer-findings-for-inbound-internet-access-in-multiple-aws-accounts.html
data "aws_availability_zones" "available" {}

locals {
  azs             = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  public_subnets  = slice([for i in range(2, 16, 2) : cidrsubnet(var.naa_vpc_cidr, 8, i)], 0, var.az_count)
  private_subnets = slice([for i in range(1, 16, 2) : cidrsubnet(var.naa_vpc_cidr, 8, i)], 0, var.az_count)
}

module "naa_vpc" {
  count   = var.naa_enabled ? 1 : 0
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.12.1"

  name               = "${var.company_prefix}-naa-vpc"
  cidr               = var.naa_vpc_cidr
  azs                = local.azs
  public_subnets     = local.public_subnets
  private_subnets    = local.private_subnets
  create_vpc         = true
  enable_nat_gateway = true
  single_nat_gateway = true
}

resource "aws_cloudformation_stack" "naa_resources" {
  count = var.naa_enabled ? 1 : 0
  name  = "naa-resources"

  parameters = {
    VpcId        = module.naa_vpc[0].vpc_id
    SubnetId     = module.naa_vpc[0].private_subnets[0]
    EmailAddress = var.email_address
    Regions      = "[${var.region}]"
    KeyPairName  = ""
  }
  capabilities = ["CAPABILITY_NAMED_IAM"]

  template_body = file("${path.module}/naa-resources.yaml")
}