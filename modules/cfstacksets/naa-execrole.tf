resource "aws_cloudformation_stack_set" "naa_execrole" {
  count            = var.naa_enabled ? 1 : 0
  permission_model = "SERVICE_MANAGED"
  name             = "naa-execrole"

  auto_deployment {
    enabled = true
  }

  capabilities = ["CAPABILITY_NAMED_IAM"]

  template_body = file("${path.module}/naa-execrole.yaml")

  parameters = {
    AuthorizedARN = "arn:aws:iam::${var.security_account_id}:role/NAAEC2Role"
  }

  lifecycle {
    ignore_changes = [administration_role_arn]
  }
}

resource "aws_cloudformation_stack_set_instance" "naa_execrole" {
  count          = var.naa_enabled ? 1 : 0
  stack_set_name = aws_cloudformation_stack_set.naa_execrole[0].name

  deployment_targets {
    organizational_unit_ids = [var.org_ou_ids["sdlc"]]
  }
}