locals {
  domain_config     = var.domain_config[var.env]
  dyn_domain_config = var.domain_config["dynamic"]
}

data "aws_route53_zone" "this" {
  name         = local.domain_config.domain_name
  private_zone = false
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.1.0"

  domain_name = local.domain_config.domain_name
  zone_id     = data.aws_route53_zone.this.zone_id

  validation_method = "DNS"

  subject_alternative_names = local.domain_config.subject_alternative_names
  wait_for_validation       = true
}

# Dynamic environment ACM
data "aws_route53_zone" "dyn" {
  count        = var.dynamic_env_support ? 1 : 0
  name         = local.dyn_domain_config.domain_name
  private_zone = false
}

module "acm_dyn" {
  count   = var.dynamic_env_support ? 1 : 0
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 5.1.0"

  domain_name = local.dyn_domain_config.domain_name
  zone_id     = data.aws_route53_zone.dyn[0].zone_id

  validation_method = "DNS"

  subject_alternative_names = local.dyn_domain_config.subject_alternative_names
  wait_for_validation       = true
}

