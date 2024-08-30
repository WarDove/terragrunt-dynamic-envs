# https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/create-a-report-of-network-access-analyzer-findings-for-inbound-internet-access-in-multiple-aws-accounts.html
resource "aws_cloudformation_stack" "naa_resources" {
  name = "naa-resources"

  parameters = {
    VpcId        = module.vpc.vpc_id
    SubnetId     = module.vpc.private_subnets[0]
    EmailAddress = var.email_address
    Regions      = "[${var.region}]"
    KeyPairName  = ""
  }
  capabilities = ["CAPABILITY_NAMED_IAM"]

  template_body = file("${path.module}/naa-resources.yaml")
}

output "naa_ec2_role" {
  value = aws_cloudformation_stack.naa_resources.outputs.NAAEC2Role
}