include "root" {
  path = find_in_parent_folders()
}

dependency "organization" {
  config_path = "../organization"
}

inputs = {
  org_ou_ids = dependency.organization.outputs.org_ou_ids
}