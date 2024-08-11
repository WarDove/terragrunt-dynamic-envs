variable "ecr_image_count" {
  default = 50
}

variable "sdlc_account_ids" {}

variable "ecr_remote_access_roles" {}

variable "deployments" {}
variable "company_prefix" {}

variable "env" {
  default = "shared"
}