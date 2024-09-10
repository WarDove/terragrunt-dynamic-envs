include "root" {
  path = find_in_parent_folders()
}

inputs = {
  dynamic = false
  gha_oidc_enabled = false
}