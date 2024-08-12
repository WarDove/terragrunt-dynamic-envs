skip                          = true
terragrunt_version_constraint = ">= 0.66"
terraform_version_constraint  = ">= 1.9.0"

locals {
  common_vars    = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  company_prefix = local.common_vars.inputs.company_prefix
  aws_env        = try(regex(local.env_regex, get_original_terragrunt_dir())[0], "shared-services")
  env_regex      = "infrastructure-live/([a-zA-Z0-9-]+)/"
  cluster_name   = "${local.company_prefix}-${local.aws_env}"
  profile        = "${local.company_prefix}-shared-services-tf"
  region         = "us-east-2"
}

inputs = merge(
  local.common_vars.inputs,
  {
    env          = local.aws_env
    region       = local.region
    account_id   = local.common_vars.inputs.org_account_ids[local.aws_env]
    cluster_name = local.cluster_name
  }
)

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket         = "${local.company_prefix}-terraform-state-shared-services"
    key            = "${local.company_prefix}/${get_path_from_repo_root()}/terraform.tfstate"
    region         = local.region
    profile        = local.profile
    encrypt        = true
    dynamodb_table = "shared-services-tfstate-lock-table"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "aws" {
      region              = "${local.region}"
      profile             = "${local.profile}"
      allowed_account_ids = ["${local.common_vars.inputs.org_account_ids[local.aws_env]}"]

      assume_role {
        role_arn = "arn:aws:iam::${local.common_vars.inputs.org_account_ids[local.aws_env]}:role/${local.common_vars.inputs.account_role_name}"
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

    provider "aws" {
      region              = "us-east-1"
      alias               = "us-east-1"
      profile             = "${local.profile}"
      allowed_account_ids = ["${local.common_vars.inputs.org_account_ids[local.aws_env]}"]

      assume_role {
        role_arn = "arn:aws:iam::${local.common_vars.inputs.org_account_ids[local.aws_env]}:role/${local.common_vars.inputs.account_role_name}"
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
