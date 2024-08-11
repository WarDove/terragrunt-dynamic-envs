resource "aws_organizations_organization" "main" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "sso.amazonaws.com",
    "account.amazonaws.com",
    "member.org.stacksets.cloudformation.amazonaws.com"
  ]

  feature_set = "ALL"
}
