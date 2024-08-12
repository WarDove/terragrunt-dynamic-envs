variable "vpc_cidr" {}
variable "company_prefix" {}
variable "env" {}
variable "region" {}

variable "az_count" {
  default = 2
}

variable "ssm_vpce" {
  default = false
}

variable "ecr_vpce" {
  default = false
}

variable "cw_vpce" {
  default = false
}