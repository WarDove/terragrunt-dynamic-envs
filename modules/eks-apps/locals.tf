locals {
  eks_app_statements = [
    {
      name = "app1" # deployment/serviceAccountName
      statements = [
        {
          effect    = "Allow"
          actions   = ["s3:GetObject"]
          resources = ["arn:aws:s3:::bucket_name/*"]
        },
        {
          effect    = "Deny"
          actions   = ["s3:DeleteObject"]
          resources = ["arn:aws:s3:::bucket_name/*"]
        }
      ]
    },
    {
      name = "app2"
      statements = [
        {
          effect    = "Allow"
          actions   = ["sqs:SendMessage"]
          resources = ["arn:aws:sqs:::queue_name"]
        }
      ]
    }
  ]

  eks_app_buckets = [
    {
      name                     = "sandbox-test-bucket-123123" # bucketName
      acl                      = null                         # ["private" "public-read" "public-read-write" "authenticated-read" "aws-exec-read" "log-delivery-write"]
      object_ownership         = "BucketOwnerEnforced"        # acl not supported
      policy                   = null
      control_object_ownership = false
      force_destroy            = true

      versioning = false
      tags       = {}
    }
  ]

  env = var.dynamic ? "dynamic" : var.env
  default_labels = {
    "kubernetes.io/environment" = local.env
    "kubernetes.io/owner"       = "Devops"
    "kubernetes.io/managed-by"  = "Terraform"
  }
}