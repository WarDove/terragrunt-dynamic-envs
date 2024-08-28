locals {
  application_policies = {
    "mono-service"             = data.aws_iam_policy_document.mono_service_policy.json
    "bff-service"              = data.aws_iam_policy_document.bff_service_policy.json
    "gotrg-worker"             = data.aws_iam_policy_document.gotrg_worker_policy.json
    "notification-worker"      = data.aws_iam_policy_document.notification_worker_policy.json
    "merge-service"            = data.aws_iam_policy_document.merge_service_policy.json
    "merge-worker"             = data.aws_iam_policy_document.merge_worker_policy.json
    "asset-worker"             = data.aws_iam_policy_document.asset_worker_policy.json
    "order-worker"             = data.aws_iam_policy_document.order_worker_policy.json
    "file-download-service"    = data.aws_iam_policy_document.file_download_service_policy.json
    "file-upload-service"      = data.aws_iam_policy_document.file_upload_service_policy.json
    "cloufront-origin-swapper" = data.aws_iam_policy_document.store_ui_cf_origin_swap_policy.json
  }
}

# IAM policy for Application Deployments
resource "aws_iam_policy" "file_upload_service_policy" {
  for_each    = var.deployments
  name        = "${each.value}-irsa-policy-${var.namespace}"
  description = "${title(each.value)} IAM policy for dedicated IRSA"
  policy      = local.application_policies[each.value]
}

data "aws_iam_policy_document" "mono_service_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::${var.company_prefix}-store-catalog-${var.namespace}",
      "arn:aws:s3:::${var.company_prefix}-asset-service-request-${var.namespace}"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "arn:aws:s3:::${var.company_prefix}-store-catalog-${var.namespace}/*",
      "arn:aws:s3:::${var.company_prefix}-asset-service-request-${var.namespace}/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      "arn:aws:sns:${var.region}:${var.account_id}:asset-domain-${var.namespace}.fifo",
      "arn:aws:sns:${var.region}:${var.account_id}:notification-domain-${var.namespace}.fifo",
      "arn:aws:sns:${var.region}:${var.account_id}:order-domain-${var.namespace}.fifo",
      "arn:aws:sns:${var.region}:${var.account_id}:organization-domain-${var.namespace}.fifo",
      "arn:aws:sns:${var.region}:${var.account_id}:shipment-domain-${var.namespace}.fifo"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
    ]
    resources = [
      "arn:aws:sqs:${var.region}:${var.account_id}:notification-${var.namespace}.fifo",
      "arn:aws:sqs:${var.region}:${var.account_id}:acumatica-worker-requests-${var.namespace}.fifo",
      "arn:aws:sqs:${var.region}:${var.account_id}:organization-${var.namespace}.fifo",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage"
    ]
    resources = [
      "arn:aws:sqs:${var.region}:${var.account_id}:acumatica-worker-requests-${var.namespace}.fifo"
    ]
  }
}

# bff-service sa role iam permissions
data "aws_iam_policy_document" "bff_service_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "arn:aws:s3:::${var.company_prefix}-store-catalog-${var.namespace}/*",
      "arn:aws:s3:::${var.company_prefix}-asset-service-request-${var.namespace}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      "arn:aws:sns:${var.region}:${var.account_id}:asset-domain-${var.namespace}.fifo",
      "arn:aws:sns:${var.region}:${var.account_id}:notification-domain-${var.namespace}.fifo",
      "arn:aws:sns:${var.region}:${var.account_id}:order-domain-${var.namespace}.fifo",
      "arn:aws:sns:${var.region}:${var.account_id}:organization-domain-${var.namespace}.fifo",
      "arn:aws:sns:${var.region}:${var.account_id}:shipment-domain-${var.namespace}.fifo"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
    ]
    resources = [
      "arn:aws:sqs:${var.region}:${var.account_id}:notification-${var.namespace}.fifo"
    ]
  }
}


# Gotrg sa role iam permissions
data "aws_iam_policy_document" "gotrg_worker_policy" {


  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "arn:aws:s3:::${var.company_prefix}-asset-additions-${var.namespace}/*",
      "arn:aws:s3:::${var.company_prefix}-asset-service-request-${var.namespace}/*",
      "arn:aws:s3:::${var.company_prefix}-asset-changes-${var.namespace}/*",
      "arn:aws:s3:::${var.company_prefix}-asset-tracking-${var.namespace}/*",
      "arn:aws:s3:::${var.company_prefix}-inventory-report-${var.namespace}/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage"
    ]
    resources = [
      "arn:aws:sqs:${var.region}:${var.account_id}:gotrg-${var.namespace}"
    ]
  }
}

# Notification-worker sa role iam permissions
data "aws_iam_policy_document" "notification_worker_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      "arn:aws:sns:${var.region}:${var.account_id}:notification-domain-${var.namespace}.fifo"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage"
    ]
    resources = [
      "arn:aws:sqs:${var.region}:${var.account_id}:notification-${var.namespace}.fifo"
    ]
  }
}


# Merge-service sa role iam permissions
data "aws_iam_policy_document" "merge_service_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      "arn:aws:sns:${var.region}:${var.account_id}:organization-domain-${var.namespace}.fifo"
    ]
  }
}

# Merge-worker sa role iam permissions
data "aws_iam_policy_document" "merge_worker_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage"
    ]
    resources = [
      "arn:aws:sqs:${var.region}:${var.account_id}:merge-${var.namespace}.fifo"
    ]
  }
}


# Asset-worker sa role iam permissions
data "aws_iam_policy_document" "asset_worker_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage"
    ]
    resources = [
      "arn:aws:sqs:${var.region}:${var.account_id}:asset-${var.namespace}.fifo"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.company_prefix}-file-uploads-${var.namespace}",
      "arn:aws:s3:::${var.namespace}-*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${var.company_prefix}-file-uploads-${var.namespace}/*",
      "arn:aws:s3:::${var.namespace}-*/*"
    ]
  }
}

# Order-worker sa role iam permissions
data "aws_iam_policy_document" "order_worker_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage"
    ]
    resources = [
      "arn:aws:sqs:${var.region}:${var.account_id}:order-${var.namespace}.fifo"
    ]
  }
}

# File-download-service sa role iam permissions
data "aws_iam_policy_document" "file_download_service_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.company_prefix}-file-download-${var.namespace}"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${var.company_prefix}-file-download-${var.namespace}/*"
    ]
  }
}

# File-upload-service sa role iam permissions
data "aws_iam_policy_document" "file_upload_service_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.company_prefix}-file-uploads-${var.namespace}",
      "arn:aws:s3:::${var.namespace}-*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::${var.company_prefix}-file-uploads-${var.namespace}/*",
      "arn:aws:s3:::${var.namespace}-*/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      "arn:aws:sns:${var.region}:${var.account_id}:file-domain-${var.namespace}.fifo"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:ConditionCheckItem",
      "dynamodb:PutItem",
      "dynamodb:DescribeTable",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem"
    ]
    resources = [
      "arn:aws:dynamodb:${var.region}:${var.account_id}:table/upload-metadata-${var.namespace}",
      "arn:aws:dynamodb:${var.region}:${var.account_id}:table/upload-schema-${var.namespace}",
      "arn:aws:dynamodb:${var.region}:${var.account_id}:table/organization-info-${var.namespace}"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${var.company_prefix}-file-download-${var.namespace}/*"
    ]
  }
}

# Store-ui deployment (cf-origin-path-swap) job sa role iam permissions
data "aws_iam_policy_document" "store_ui_cf_origin_swap_policy" {
  statement {
    effect = "Allow"
    actions = [
      "cloudfront:GetDistribution",
      "cloudfront:GetDistributionConfig",
      "cloudfront:UpdateDistribution",
      "cloudfront:CreateInvalidation",
      "cloudfront:ListDistributions"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.company_prefix}-store-ui-${var.namespace}"
    ]
  }
}
