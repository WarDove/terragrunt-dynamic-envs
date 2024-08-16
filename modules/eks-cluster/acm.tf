locals {
  domain_config = var.domain_config[var.env]
}

data "aws_route53_zone" "this" {
  count        = !local.domain_config.create ? 1 : 0
  name         = local.domain_config.domain_name
  private_zone = false
}

resource "aws_route53_zone" "this" {
  count = local.domain_config.create ? 1 : 0
  name  = local.domain_config.domain_name
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.1.0"

  domain_name = local.domain_config.domain_name
  zone_id     = local.domain_config.create ? aws_route53_zone.this[0].zone_id : data.aws_route53_zone.this[0].zone_id

  validation_method = "DNS"

  subject_alternative_names = local.domain_config.subject_alternative_names
  wait_for_validation       = true
}