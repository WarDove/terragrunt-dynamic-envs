output "naa_ec2_role" {
  value = join("", aws_cloudformation_stack.naa_resources[*].outputs.NAAEC2Role)
}