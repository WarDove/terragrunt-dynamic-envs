skip                          = true
terragrunt_version_constraint = ">= 0.66"
terraform_version_constraint  = ">= 1.9.0"

dependencies {
  paths = ["${get_repo_root()}/infrastructure-org/root/cfstacksets"]
}

terraform {
  source = "${get_repo_root()}/modules/${basename(get_terragrunt_dir())}"
}

locals {
  common_vars        = read_terragrunt_config(find_in_parent_folders("common.hcl"))
  secret_vars        = yamldecode(sops_decrypt_file(find_in_parent_folders("secrets.yaml")))
  company_prefix     = local.common_vars.inputs.company_prefix
  env                = try(regex(local.env_regex, get_original_terragrunt_dir())[0], "shared-services")
  env_regex          = "infrastructure-live/([a-zA-Z0-9-]+)/"
  az_count           = local.env == "production" ? 3 : 2
  cluster_name       = "${local.company_prefix}-${local.env}"
  profile            = "${local.company_prefix}-shared-services-tf"
  kubeconfig_profile = "${local.company_prefix}-${local.env}-tf"
  region             = "us-east-2"

}

inputs = merge(
  local.common_vars.inputs,
  local.secret_vars,
  {
    env                = local.env
    dev_only           = true
    region             = local.region
    account_id         = local.common_vars.inputs.org_account_ids[local.env]
    cluster_name       = local.cluster_name
    kubeconfig_profile = local.kubeconfig_profile
    az_count           = local.az_count
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
      allowed_account_ids = ["${local.common_vars.inputs.org_account_ids[local.env]}"]

      assume_role {
        role_arn = "arn:aws:iam::${local.common_vars.inputs.org_account_ids[local.env]}:role/${local.common_vars.inputs.account_role_name}"
      }

      default_tags {
        tags = {
          Environment = "${local.env}"
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
      allowed_account_ids = ["${local.common_vars.inputs.org_account_ids[local.env]}"]

      assume_role {
        role_arn = "arn:aws:iam::${local.common_vars.inputs.org_account_ids[local.env]}:role/${local.common_vars.inputs.account_role_name}"
      }

      default_tags {
        tags = {
          Environment = "${local.env}"
          ManagedBy   = "terraform"
          DeployedBy  = "terragrunt"
          Creator     = "${get_env("USER", "NOT_SET")}"
          Company     = "${local.company_prefix}"
        }
      }
    }
EOF
}
