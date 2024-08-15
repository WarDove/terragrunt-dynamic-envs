module "ecr" {
  for_each = var.deployments
  source   = "terraform-aws-modules/ecr/aws"
  version  = "~> 2.2.1"

  repository_name             = each.value
  repository_read_access_arns = local.remote_node_roles

  repository_lifecycle_policy = jsonencode({
    rules = local.rules
  })
}
