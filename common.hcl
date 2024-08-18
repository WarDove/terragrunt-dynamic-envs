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
  root_account_id    = local.core_account_ids["root"]
  account_role_name  = "terraform-execution-role"
  org_units          = ["SDLC", "Core"]
  node_role_name     = "eks-node-role"
  albc_role_name     = "eks-albc-role"
  es_role_name       = "eks-es-role"
  ed_role_name       = "eks-ed-role"

  domain_config = {
    development = {
      domain_name               = "dev.huseynov.net",
      subject_alternative_names = ["*.dev.huseynov.net"]
    }
    production = {
      domain_name               = "huseynov.net",
      subject_alternative_names = ["*.huseynov.net"]
    }
  }
}



