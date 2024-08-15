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

variable "region" {
  type = string
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

################################################################################
# AWS Load Balancer Controller
################################################################################

variable "enable_albc" {
  type = bool
}

variable "albc_version" {
  type = string
}

variable "eks_vpc_id" {
  type = string
}