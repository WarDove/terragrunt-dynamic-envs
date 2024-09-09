module "iam_github_oidc_provider" {
  source         = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-provider"
  version        = "~> 5.44.0"
  client_id_list = []
  create         = true
}

data "aws_iam_policy_document" "eks_vpc_cni_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:rms1000watt/*"]
    }

    principals {
      identifiers = [module.iam_github_oidc_provider.arn]
      type        = "Federated"
    }
  }
}

# resource "aws_iam_role" "eks_ebs_csi_driver_role" {
#   assume_role_policy = data.aws_iam_policy_document.eks_ebs_csi_driver_role[0].json
#   name               = "${local.cluster_name}-ebs-csi-driver-role"
#   tags               = local.default_tags
# }
