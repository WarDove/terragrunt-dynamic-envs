resource "aws_cloudformation_stack_set" "naa_execrole" {
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
  stack_set_name = aws_cloudformation_stack_set.naa_execrole.name

  deployment_targets {
    organizational_unit_ids = [var.org_ou_ids["sdlc"]]
  }
}