resource "aws_ecr_repository" "main" {
  for_each             = local.deployments
  name                 = "${var.company_prefix}/${each.value}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_lifecycle_policy" "main" {
  for_each   = aws_ecr_repository.main
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 10
        description  = "Keeping the 100 most recent images tagged with prefix 'stable'"
        action = {
          type = "expire"
        }
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["stable"]
          countType     = "imageCountMoreThan"
          countNumber   = 100
        }
      },
      {
        rulePriority = 20
        description  = "Keeping the ${var.ecr_image_count} most recent images regardless of their tags"
        action = {
          type = "expire"
        }
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.ecr_image_count
        }
      },
    ]
  })
}

data "aws_iam_policy_document" "main" {
  statement {
    sid    = "AllowPullFromFargate"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = local.remote_access_roles
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability"
    ]
  }
}

resource "aws_ecr_repository_policy" "ecr_cross_account_access" {
  for_each   = aws_ecr_repository.main
  repository = each.value.name
  policy     = data.aws_iam_policy_document.main.json
}