variable "cluster_version" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "env" {
  type = string
}

variable "enable_karpenter" {
  type    = bool
  default = false
}

variable "enable_albc" {
  type    = bool
  default = false
}

variable "enable_es" {
  type    = bool
  default = false
}

variable "node_role_name" {
  type = string
}

variable "albc_role_name" {
  type = string
}

variable "es_role_name" {
  type = string
}