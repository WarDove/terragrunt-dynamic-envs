skip = true

locals {
  account_role_name = "terraform-execution-role"
  aws_env           = try(regex(local.env_regex, get_original_terragrunt_dir())[0], "shared-services")
  company_prefix    = "mycompany"
  env_regex         = "infrastructure-live/([a-zA-Z0-9-]+)/"
  profile           = "${local.company_prefix}-shared-services-sso"
  region            = "us-east-2"

  account_mapping = {
    root            = 166733594871
    development     = 222222222222
    production      = 000000000000
    shared-services = 011528295601
  }
}

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
      region = "${local.region}"
      profile = "${local.profile}"
      allowed_account_ids = [
        "${local.account_mapping[local.aws_env]}"
      ]

      assume_role {
        role_arn = "arn:aws:iam::${local.account_mapping[local.aws_env]}:role/${local.account_role_name}"
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
