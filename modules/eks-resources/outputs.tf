output "enable_karpenter" {
  value = var.enable_karpenter
}

output "enable_es" {
  value = var.enable_es
}

output "node_instance_profile_name" {
  value = join("", module.karpenter[0].instance_profile_name)
}