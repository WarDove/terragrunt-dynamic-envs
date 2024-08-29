data "aws_iam_policy_document" "application_policy" {
  for_each = var.app_statements

  dynamic "statement" {
    for_each = each.value

    content {
      effect  = statement.value.effect
      actions = statement.value.action
    }
  }
}

resource "aws_iam_policy" "application_policy" {
  for_each    = var.app_statements
  name        = "${each.key}-irsa-policy-${var.namespace}"
  description = "${title(each.key)} IAM policy for dedicated IRSA"
  policy      = data.aws_iam_policy_document.application_policy[each.key].json
}