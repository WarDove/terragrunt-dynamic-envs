variable "cluster_name" {
  type = string
}

variable "eks_sg_id" {
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

variable "domain_config" {
  type = map(object({
    domain_name               = string
    subject_alternative_names = list(string)
  }))
}

variable "acm_certificate_arn" {
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

variable "account_id" {
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

variable "albc_role_name" {
  type = string
}

variable "albc_backend_sg_id" {
  type = string
}

variable "eks_vpc_id" {
  type = string
}

################################################################################
# External Secrets Operator
################################################################################

variable "enable_es" {
  type = bool
}

variable "es_role_name" {
  type = string
}

variable "es_version" {
  type = string
}

################################################################################
# External DNS Operator
################################################################################

variable "enable_ed" {
  type = bool
}

variable "ed_role_name" {
  type = string
}

variable "ed_version" {
  type = string
}

################################################################################
# Argo
################################################################################

variable "argocd_version" {
  type = string
}

# variable "github_webhook" {
#   type = bool
# }

#variable "github_webhook_secret" {}


variable "enable_argocd" {
  type = bool
}


################################################################################
# Reloader
################################################################################
variable "enable_reloader" {
  type = bool
}

variable "reloader_version" {
  type = string
}