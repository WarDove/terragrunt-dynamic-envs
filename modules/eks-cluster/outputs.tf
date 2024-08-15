output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "eks_vpc_id" {
  value = var.vpc_id
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
  value = var.enable_karpenter ? module.karpenter[0].queue_name : ""
}

output "karpenter_role_arn" {
  value = var.enable_karpenter ? module.karpenter[0].iam_role_arn : ""
}

output "node_iam_role_arn" {
  value = var.enable_karpenter ? module.karpenter[0].node_iam_role_arn : ""
}

output "node_instance_profile_name" {
  value = var.enable_karpenter ? module.karpenter[0].instance_profile_name : ""
}

################################################################################
# AWS Load Balancer Controller
################################################################################

output "enable_albc" {
  value = var.enable_albc
}

################################################################################
# External Secrets Operator
################################################################################

output "enable_es" {
  value = var.enable_es
}