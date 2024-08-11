variable "ecr_image_count" {
  default = 50
}

variable "account_id" {}
variable "region" {}
variable "company_prefix" {}

variable "sdlc_account_ids" {
  type = map(string)
}

variable "deployments" {
  type = list(string)
}

