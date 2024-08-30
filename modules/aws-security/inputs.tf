variable "vpc_cidr" {
  type    = string
  default = "10.50.0.0/16"
}

variable "az_count" {
  type    = number
  default = 1
}

variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "company_prefix" {
  type = string
}

variable "email_address" {
  type    = string
  default = "tarlan@huseynov.net"
}