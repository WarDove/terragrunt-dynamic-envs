locals {
  sdlc_account_ids = {
    development = "011528295573"
    production  = "253490758009"
  }

  core_account_ids = {
    root            = "166733594871"
    shared-services = "011528295601"
  }
}

inputs = {
  deployments = [
    "app1",
    "app2",
    "app3"
  ]

  company_prefix     = "mycompany"
  sdlc_account_ids   = local.sdlc_account_ids
  core_account_ids   = local.core_account_ids
  org_account_ids    = merge(local.sdlc_account_ids, local.core_account_ids)
  shared_services_id = local.core_account_ids["shared-services"]
  account_role_name  = "terraform-execution-role"
  org_units          = ["SDLC", "Core"]
}



