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

################################################################################
# Karpenter
################################################################################

variable "create_karpenter" {
  type    = bool
  default = false
}

variable "karpenter_version" {
  type    = string
  default = "0.37.0"
}