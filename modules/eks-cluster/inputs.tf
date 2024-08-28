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

variable "dynamic_env_support" {
  type    = bool
  default = false
}