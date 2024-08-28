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

variable "account_id" {
  type = string
}

variable "domain_config" {
  type = map(object({
    domain_name               = string
    subject_alternative_names = list(string)
  }))
}

variable "oidc_provider_arn" {
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

variable "node_role_name" {
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

################################################################################
# External Secrets Operator
################################################################################

variable "enable_es" {
  type = bool
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

variable "ed_version" {
  type = string
}

################################################################################
# Argo
################################################################################

variable "argo_cd_version" {
  type = string
}

variable "argo_rollouts_version" {
  type = string
}

# variable "github_webhook" {
#   type = bool
# }

#variable "github_webhook_secret" {}


variable "enable_argo" {
  type = bool
}

variable "github_webhook" {
  type    = bool
  default = true
}

variable "github_webhook_secret" {
  type      = string
  sensitive = true
}

variable "gitops_repo_url" {
  type = string
}

variable "gitops_pat" {
  type      = string
  sensitive = true
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