variable "namespace" {}
variable "oidc_provider_arn" {}
variable "env" {}



variable "cluster_certificate_authority_data" {}
variable "cluster_endpoint" {}
variable "kubeconfig_profile" {}
variable "cluster_name" {}

# variable "company_prefix" {}
# variable "account_id" {}
# variable "region" {}
#
# variable "deployments" {
#   type = set(string)
# }
#
variable "dynamic" {
  type    = bool
  default = false
}