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

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "fargate_iam_role_arns" {
  value = [for k, v in module.eks.fargate_profiles : v.iam_role_arn]
}
