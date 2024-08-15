output "ecr_registry" {
  value = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com"
}
