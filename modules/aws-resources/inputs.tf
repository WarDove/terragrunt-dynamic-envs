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