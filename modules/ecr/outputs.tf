output "account_id" {
  value = data.aws_caller_identity.current.id
}

output "ecr_registry" {
  value = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com"
}
