output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "eks_vpc_id" {
  value = var.vpc_id
}

output "eks_sg_id" {
  value = module.eks.cluster_security_group_id
}

# output "acm_certificate_arn" {
#   value = module.acm.acm_certificate_arn
# }
#
# output "acm_dyn_certificate_arn" {
#   value = join("", module.acm_dyn[*].acm_certificate_arn)
# }

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

################################################################################
# Fargate
################################################################################

output "fargate_iam_role_arns" {
  value = [for k, v in module.eks.fargate_profiles : v.iam_role_arn]
}
