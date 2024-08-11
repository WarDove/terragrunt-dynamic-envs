variable "shared_services_account_id" {
  type        = string
  description = "The Shared-services AWS account ID that can assume terraform role"
}

variable "org_ou_ids" {
  type = map(string)
}