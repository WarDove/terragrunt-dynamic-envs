variable "ecr_image_count" {
  type    = number
  default = 50
}

variable "account_id" {
  type = string
}

variable "region" {
  type = string
}

variable "company_prefix" {
  type = string
}

variable "sdlc_account_ids" {
  type = map(string)
}

variable "deployments" {
  type = list(string)
}

variable "dev_node_iam_role_arn" {
  type = string
}

