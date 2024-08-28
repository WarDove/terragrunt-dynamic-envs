variable "app_statements" {
  type = map(object({
    statements = list(object({
      actions   = list(string)
      resources = list(string)
    }))
  }))
  default = {}
}

variable "namespace" {}
variable "oidc_provider_arn" {}