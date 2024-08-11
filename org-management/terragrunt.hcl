skip = true

locals {
  account_role_name = "terraform-execution-role" # This role has to be created in root account
  aws_env           = "root"
  company_prefix    = "mycompany"
  profile           = "${local.company_prefix}-root-sso"
  region            = "eu-central-1"

  account_mapping = {
    root            = "166733594871"
    development     = "222222222222"
    production      = "000000000000"
    shared-services = "011528295601"
  }
}

inputs = {
  shared_services_account_id = local.account_mapping["shared-services"]
  org_units                  = ["SDLC"]
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket         = "${local.company_prefix}-terraform-state-root"
    key            = "${local.company_prefix}/${get_path_from_repo_root()}/terraform.tfstate"
    region         = local.region
    profile        = local.profile
    encrypt        = true
    dynamodb_table = "root-tfstate-lock-table"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "aws" {
      region = "${local.region}"
      profile = "${local.profile}"
      allowed_account_ids =["${local.account_mapping["root"]}"]

      assume_role {
        role_arn = "arn:aws:iam::${local.account_mapping["root"]}:role/${local.account_role_name}"
      }

      default_tags {
        tags = {
          Environment = "${local.aws_env}"
          ManagedBy   = "terraform"
          DeployedBy  = "terragrunt"
          Creator     = "${get_env("USER", "NOT_SET")}"
          Company     = "${local.company_prefix}"
        }
      }
    }
EOF
}
