variable "cw_logs_enabled" {
  type = bool
  default = false
}

variable "cluster_version" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}