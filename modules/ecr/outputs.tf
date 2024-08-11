output "account_id" {
  value = var.account_id
}

output "ecr_registry" {
  value = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com"
}
