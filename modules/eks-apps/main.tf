module "eks_app_permissions" {
  source            = "./modules/eks-app-permissions"
  namespace         = var.namespace
  oidc_provider_arn = var.oidc_provider_arn
  app_statements    = {}
}

locals {
  eks_app_buckets = [
    {
      store-catalog = {
        versioning = true
        object_ownership = "BucketOwnerPreferred"

      }
    }

  ]
}

module "eks_app_buckets" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.1.2"

  bucket                   = "${var.cluster_name}-flow-logs"
  acl                      = "private"
  control_object_ownership = true
  force_destroy            = true
  object_ownership         = "ObjectWriter"
}