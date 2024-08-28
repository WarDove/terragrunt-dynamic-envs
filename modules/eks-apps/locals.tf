locals {
  env = var.dynamic ? "dynamic" : var.env
  default_labels = {
    "kubernetes.io/environment" = local.env
    "kubernetes.io/owner"       = "Devops"
    "kubernetes.io/managed-by"  = "Terraform"
  }
}