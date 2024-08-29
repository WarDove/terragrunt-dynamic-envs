locals {
  eks_app_statements = [
    {
      name = "app1"
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
      name                     = "sandbox-test-bucket-123123"
      acl                      = null                  # ["private" "public-read" "public-read-write" "authenticated-read" "aws-exec-read" "log-delivery-write"]
      object_ownership         = "BucketOwnerEnforced" # acl not supported
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
  acl                      = lookup(each.value, "acl", "null")
  policy                   = lookup(each.value, "policy", null)
  control_object_ownership = lookup(each.value, "control_object_ownership", false)
  force_destroy            = lookup(each.value, "force_destroy", true)
  object_ownership         = lookup(each.value, "object_ownership", "BucketOwnerEnforced")

  versioning = {
    enabled = lookup(each.value, "versioning", false)
  }

  tags = lookup(each.value, "tags", {})
}