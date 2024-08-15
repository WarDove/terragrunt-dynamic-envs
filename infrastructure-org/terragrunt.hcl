skip = true

terraform {
  source = "${get_repo_root()}/modules/${basename(get_terragrunt_dir())}"
}

locals {
  common_vars = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  env         = "root"
  env_regex   = "infrastructure-live/([a-zA-Z0-9-]+)/"
  profile     = "${local.common_vars.inputs.company_prefix}-root-sso"
  region      = "eu-central-1"
}

inputs = merge(
  local.common_vars.inputs,
  {
    env        = local.env
    region     = local.region
    account_id = local.common_vars.inputs.org_account_ids[local.env]
  }
)

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket         = "${local.common_vars.inputs.company_prefix}-terraform-state-root"
    key            = "${local.common_vars.inputs.company_prefix}/${get_path_from_repo_root()}/terraform.tfstate"
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
    terraform {
      required_providers {
        aws = {
          source = "hashicorp/aws"
          version = "~> 5.60"
        }
      }
    }

    provider "aws" {
      region = "${local.region}"
      profile = "${local.profile}"
      allowed_account_ids =["${local.common_vars.inputs.org_account_ids[local.env]}"]

      assume_role {
        role_arn = "arn:aws:iam::${local.common_vars.inputs.org_account_ids[local.env]}:role/${local.common_vars.inputs.account_role_name}"
      }

      default_tags {
        tags = {
          Environment = "${local.env}"
          ManagedBy   = "terraform"
          DeployedBy  = "terragrunt"
          Creator     = "${get_env("USER", "NOT_SET")}"
          Company     = "${local.common_vars.inputs.company_prefix}"
        }
      }
    }
EOF
}
