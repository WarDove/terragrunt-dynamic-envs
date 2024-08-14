variable "cluster_name" {
  type = string
}

variable "cluster_endpoint" {
  type = string
}

variable "cluster_certificate_authority_data" {
  type = string
}

variable "kubeconfig_profile" {
  type = string
}

variable "env" {
  type = string
}

variable "az_count" {
  type = number
}

################################################################################
# Karpenter
################################################################################

variable "enable_karpenter" {
  type    = bool
  default = false
}

variable "karpenter_version" {
  type = string
}

variable "karpenter_role_arn" {
  type = string
}

variable "karpenter_termination_queue_name" {
  type = string
}

variable "node_instance_profile_name" {
  type = string
}