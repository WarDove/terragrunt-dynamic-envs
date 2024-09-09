module "iam_github_oidc_provider" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-provider"
  version = "~> 5.44.0"
  create  = true
}

data "aws_iam_policy_document" "gha_oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringLike"
      variable = "${replace(module.iam_github_oidc_provider.url, "https://", "")}:sub"
      values   = ["repo:${var.company_prefix}/*"]
    }

    condition {
      test     = "StringLike"
      variable = "${replace(module.iam_github_oidc_provider.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [module.iam_github_oidc_provider.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "gha_role" {
  assume_role_policy = data.aws_iam_policy_document.gha_oidc_assume_role_policy.json
  name               = "GitHubActionsRole"
}
