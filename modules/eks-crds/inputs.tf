variable "node_instance_profile_name" {
  type = string
}

variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "az_count" {
  type = number
}

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

variable "enable_karpenter" {
  type = bool
}

variable "enable_es" {
  type = bool
}

variable "enable_arc" {
  type = bool
}

variable "arc_version" {
  type = string
}

variable "arc_runner_group" {
  default = "default"
}

variable "arc_pat" {
  description = "To enable ARC to authenticate to GitHub, generate a personal access token (classic). For more information, see Authenticating to the GitHub API."
  sensitive   = true
  type        = string
}

variable "github_config_url" {
  description = "The URL of your repository, organization, or enterprise. This is the entity that the runners will belong to."
  type        = string
}

