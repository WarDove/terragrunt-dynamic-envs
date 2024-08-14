output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
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