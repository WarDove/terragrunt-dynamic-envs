module "eks_app_permissions" {
  source            = "./modules/eks-app-permissions"
  namespace         = var.namespace
  oidc_provider_arn = var.oidc_provider_arn
  app_statements = {
    #     mono-service = {
    #       actions   = [],
    #       resources = []
  }
}

locals {
  eks_app_buckets = [
    {
      name                     = "sandbox-test-bucket-123123"
      acl                      = "private"
      object_ownership         = "BucketOwnerEnforced"
      policy                   = null
      control_object_ownership = false
      force_destroy            = true

      versioning = false
      tags       = {}
    }
  ]
}

module "eks_app_buckets" {
  for_each = { for bucket in local.eks_app_buckets : bucket.name => bucket }
  source   = "terraform-aws-modules/s3-bucket/aws"
  version  = "~> 4.1.2"

  bucket                   = each.key
  acl                      = lookup(each.value, "acl", "private")
  policy                   = lookup(each.value, "policy", null)
  control_object_ownership = lookup(each.value, "control_object_ownership", false)
  force_destroy            = lookup(each.value, "force_destroy", true)
  object_ownership         = lookup(each.value, "object_ownership", "BucketOwnerEnforced")

  versioning = {
    enabled = lookup(each.value, "versioning", false)
  }

  tags = lookup(each.value, "tags", {})
}