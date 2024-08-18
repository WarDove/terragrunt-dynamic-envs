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

variable "domain_config" {
  type = map(object({
    domain_name               = string
    subject_alternative_names = list(string)
  }))
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

variable "enable_ed" {
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

variable "ed_role_name" {
  type = string
}