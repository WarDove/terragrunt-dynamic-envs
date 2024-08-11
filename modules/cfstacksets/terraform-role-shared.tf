resource "aws_cloudformation_stack_set" "terraform_role_shared" {
  permission_model = "SERVICE_MANAGED"
  name             = "terraform-execution-role-shared"

  auto_deployment {
    enabled = true
  }

  capabilities = ["CAPABILITY_NAMED_IAM"]

  template_body = jsonencode({
    AWSTemplateFormatVersion = "2010-09-09",
    Description              = "AWS CloudFormation Template to create an IAM Role named 'terraform-execution-role' and attach the 'AdministratorAccess' AWS managed policy. The role can be assumed by an external account with a matching condition.",
    Resources = {
      OrgRole = {
        Type = "AWS::IAM::Role",
        Properties = {
          RoleName = "terraform-execution-role",
          AssumeRolePolicyDocument = {
            Version = "2012-10-17",
            Statement = [
              {
                Effect = "Allow",
                Principal = {
                  AWS = ["arn:aws:iam::${var.shared_services_id}:root"]
                },
                Action = ["sts:AssumeRole"]
              }
            ]
          },
          ManagedPolicyArns = [
            "arn:aws:iam::aws:policy/AdministratorAccess"
          ]
        }
      }
    }
  })
}

resource "aws_cloudformation_stack_set_instance" "terraform_role_shared" {
  stack_set_name = aws_cloudformation_stack_set.terraform_role_shared.name
  deployment_targets {
    organizational_unit_ids = [var.org_ou_ids["core"]]
    account_filter_type     = "DIFFERENCE"
    accounts                = [var.root_account_id]
  }
}