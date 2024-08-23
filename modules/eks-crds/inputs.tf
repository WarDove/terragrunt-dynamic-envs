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