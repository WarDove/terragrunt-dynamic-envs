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

resource "aws_organizations_organizational_unit" "main" {
  for_each  = var.org_units
  name      = each.value
  parent_id = aws_organizations_organization.main.roots[0].id
}