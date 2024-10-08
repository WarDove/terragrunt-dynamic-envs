variable "shared_services_id" {
  type        = string
  description = "The Shared-services AWS account ID"
}

variable "root_account_id" {
  type        = string
  description = "The Master AWS account ID"
}

variable "org_ou_ids" {
  type = map(string)
}

variable "security_account_id" {
  type = string
}

variable "naa_enabled" {
  type    = bool
  default = false
}