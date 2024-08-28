variable "cluster_name" {}
variable "oidc_provider_arn" {}
variable "kubeconfig_profile" {}
variable "namespace" {}
variable "cluster_certificate_authority_data" {}
variable "cluster_endpoint" {}

variable "deployments" {
  type = set(string)
}

variable "dynamic_env" {
  type    = bool
  default = false
}