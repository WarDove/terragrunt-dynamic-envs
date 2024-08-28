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

output "acm_certificate_arn" {
  value = module.acm.acm_certificate_arn
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

################################################################################
# Fargate
################################################################################

output "fargate_iam_role_arns" {
  value = [for k, v in module.eks.fargate_profiles : v.iam_role_arn]
}

################################################################################
# Karpenter
################################################################################

output "enable_karpenter" {
  value = var.enable_karpenter
}

output "karpenter_termination_queue_name" {
  value = join("", module.karpenter[*].queue_name)
}

output "karpenter_role_arn" {
  value = join("", module.karpenter[*].iam_role_arn)
}

output "node_iam_role_arn" {
  value = join("", module.karpenter[*].node_iam_role_arn)
}

output "node_instance_profile_name" {
  value = join("", module.karpenter[*].instance_profile_name)
}

################################################################################
# AWS Load Balancer Controller
################################################################################

output "enable_albc" {
  value = var.enable_albc
}

output "albc_backend_sg_id" {
  value = join("", aws_security_group.albc_backend_sg[*].id)
}

################################################################################
# External Secrets Operator
################################################################################

output "enable_es" {
  value = var.enable_es
}

################################################################################
# External DNS Operator
################################################################################

output "enable_ed" {
  value = var.enable_ed
}