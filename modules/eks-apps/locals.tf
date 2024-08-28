locals {
  default_labels = {
    "kubernetes.io/environment" = var.cluster_name
    "kubernetes.io/owner"       = "Devops"
    "kubernetes.io/managed-by"  = "Terraform"
  }
}