variable "domain_config" {
  type = map(object({
    domain_name               = string
    subject_alternative_names = list(string)
  }))
}

variable "dynamic" {
  type    = bool
  default = false
}

variable "env" {
  type = string
}

variable "company_prefix" {
  type = string
}

variable "gha_oidc_enabled" {
  type    = bool
  default = false
}