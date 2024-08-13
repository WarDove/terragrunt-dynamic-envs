include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "${get_repo_root()}/modules/eks-vpc"
}

inputs = {
  az_count     = 2
  eks_vpc_cidr = "10.2.0.0/16"
}