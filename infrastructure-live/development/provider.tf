# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
provider "aws" {
  region  = "us-east-2"
  profile = "mycompany-shared-services-sso"
  allowed_account_ids = [
    "011528295601"
  ]

  assume_role {
    role_arn = "arn:aws:iam::011528295601:role/terraform-execution-role"
  }

  default_tags {
    tags = {
      Environment = "shared-services"
      ManagedBy   = "terraform"
      DeployedBy  = "terragrunt"
      Creator     = "thuseynov"
      Company     = "mycompany"
    }
  }
}
