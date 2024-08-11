resource "aws_cloudformation_stack_set" "terraform_role" {
  permission_model        = "SERVICE_MANAGED"
  name                    = "terraform-execution-role"

  auto_deployment {
    enabled = true
  }

  capabilities = ["CAPABILITY_NAMED_IAM"]


  template_body = jsonencode({
    AWSTemplateFormatVersion = "2010-09-09",
    Description              = "AWS CloudFormation Template to create an IAM Role named 'terraform-execution-role' and attach the 'AdministratorAccess' AWS managed policy. The role can be assumed by an external account with the same role name.",
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
                  AWS = ["arn:aws:iam::${var.shared_services_account_id}:role/terraform-execution-role"]
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
