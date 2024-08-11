output "org_ou_ids" {
  value = { for org_ou_id in aws_organizations_organizational_unit.main : lower(org_ou_id.name) => org_ou_id.id }
}