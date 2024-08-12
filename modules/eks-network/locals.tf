data "aws_availability_zones" "current" { state = "available" }

locals {
  az_names                         = data.aws_availability_zones.current.names
  cluster_name                     = "${var.company_prefix}-${var.env}"
  default_tags_karpenter_discovery = { "karpenter.sh/discovery" = local.cluster_name }
}